%{
#include <ctype.h>
#include <limits.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

typedef enum test_label_t
{
    TEST_NULL           = 0x0,
    TEST_TARGET         = 0x1,
    TEST_SUITE_BEGIN    = 0x2,
    TEST_SUITE_END      = ~0x2,
    TEST_CASE_BEGIN     = 0x4,
    TEST_CASE_END       = ~0x4,
    TEST_BODY_BEGIN     = 0x8,
    TEST_BODY_END       = ~0x8,
    ASSERTION           = 0x10
}test_label_t;

typedef struct linked_node_t
{
    const void*             data;
    struct linked_node_t    *next;
}linked_node_t;

typedef struct test_target_t
{
    const char* name;
    int         line;
}test_target_t;

typedef struct assertion_t
{
    const char* name;
}assertion_t;

typedef struct assertion_call_t
{
    const char* name;
    char*       param_list;
}assertion_call_t;

typedef enum code_type_t
{
    CODE_BLOCK,
    ASSERTION_CALL
}code_type_t;

typedef struct code_block_t
{
    const char* begin;
    const char* end;
}code_block_t;

typedef struct code_t
{
    code_type_t code_type;
    union
    {
        code_block_t        code_block;
        assertion_call_t    assertion_call;
    };
}code_t;

typedef struct test_body_t
{
    int             line;
    const char*     prev_text;
    linked_node_t   *code_head, **cur_code;
}test_body_t;

typedef struct test_case_t
{
    const char*     name;
    int             line;
    code_block_t    code;
}test_case_t;

typedef struct test_suite_t
{
    const char*     name;
    int             line;
    test_body_t     *test_body;
    linked_node_t   *test_case_head, **cur_test_case;
}test_suite_t;

typedef struct code_buffer_t
{
    char*   buf;
    size_t  size;
}code_buffer_t;

static linked_node_t *_test_target_head_,   **_cur_test_target_ = &_test_target_head_;
static linked_node_t *_test_suite_head_,    **_cur_test_suite_  = &_test_suite_head_;
static linked_node_t *_assertion_head_,     **_cur_assertion_   = &_assertion_head_;

static const int    ESC_LEN = 1;
static test_label_t _context_label_;
static char         _test_dir_[PATH_MAX];
static const char*  TEST_MMT_FILE_NAME;
static const char*  BUILTIN_MMS     = "builtin_mms";
static const char*  ZLIB_MMIX       = "zLibMMIX";
static const char*  ASSERTION_DIR   = "testing/assertion";

static const char* DATA_SEGMENT_HEAD = \
"               LOC Data_Segment\n"
"               GREG @\n"
"test_result    GREG\n"
"suite_result   GREG\n"
"case_result    GREG\n"
"tmp_reg        GREG\n"
"NEW_LINE       BYTE #a,0\n"
"TEST_ALL_STR   BYTE \"  TEST_ALL\",0\n"
"TEST_SUITE_STR BYTE \"  TEST_SUITE\",0\n"
"TEST_CASE_STR  BYTE \"  TEST_CASE \",0\n"
"BLANK_STR      BYTE \"        \",0\n"
"PASSED_STR     BYTE \"[PASSED]\",0\n"
"FAILED_STR     BYTE \"[FAILED]\",0\n\n";
static const char* TEXT_SEGMENT_HEAD    = "\n   LOC #100\n";
static const char* MAIN_HEAD            = "Main JMP @+4\n";

static const char*  GREG_BASE_ADDR                  = " GREG @\n";
static const char*  TEST_SUITE_PREFIX_FORMAT        = " PREFIX :%s:\n";
static const char*  TEST_CASE_PREFIX_FORMAT         = " PREFIX :%s:%s:\n";
static const char*  PREFIX_END                      = " PREFIX :\n";
static const char*  TEST_SUITE_NAME_FORMAT          = "suite_name   BYTE \" %s \",0\n";
static const char*  TEST_CASE_NAME_FORMAT           = "case_name    BYTE \" %s \",0\n";
static const char*  ASSERTION_LDA_FORMAT            = " LDA     $%d,%s\n";
static const char*  ASSERTION_PUSHJ_FORMAT          = " PUSHJ   $0,:testing:assertion:%s\n";
static const int    ASSERTION_LDA_FORMAT_LEN_DIFF   = 3;
static const int    ASSERTION_PUSHJ_FORMAT_LEN_DIFF = 2;
static const char*  AFTER_ASSERTION_CALL_FORMAT = \
"   CSNZ    :case_result,$0,1\n"
"   CSNZ    :suite_result,$0,1\n"
"   CSNZ    :test_result,$0,1\n";
static const char*  PRINT_STR_FORMAT = \
"   LDA     $255,%s\n"
"   TRAP    0,:Fputs,:StdOut\n";
static const char*  PRINT_RESULT_FORMAT = \
"   LDA     $255,:FAILED_STR\n"
"   LDA     :tmp_reg,:PASSED_STR\n"
"   CMP     $0,%s,0\n"
"   CSZ     $255,$0,:tmp_reg\n"
"   TRAP    0,:Fputs,:StdOut\n"
"   SET     %s,0\n";

#define LIST_FORWARD(node)              node = &(*node)->next
#define LIST_FOREACH(node)              while (node) {
#define LIST_FOREACH_END(node)          node = node->next; }
#define ADD_CONTEXT_LABEL(test_label)   _context_label_ |= test_label
#define RM_CONTEXT_LABEL(test_label)    _context_label_ &= ~test_label
#define GET_TEST_NAME(data)             (*(char**)data)
#define GET_TEST_LINE(data)             ((int)*((char**)data + 1))
#define GET_TEST_TARGET(node)           ((test_target_t*)(node)->data)
#define GET_TEST_SUITE(node)            ((test_suite_t*)(node)->data)
#define GET_TEST_CASE(node)             ((test_case_t*)(node)->data)
#define GET_ASSERTION(node)             ((assertion_t*)(node)->data)
#define GET_CODE(node)                  ((code_t*)(node)->data)
#define GET_CODE_BLOCK(code)            ((code_block_t*)(&code->code_block))
#define GET_ASSERTION_CALL(code)        ((assertion_call_t*)(&code->assertion_call))
#define GET_CUR_TEST_SUITE()            GET_TEST_SUITE(*_cur_test_suite_)
#define GET_CUR_TEST_CASE(test_suite)   GET_TEST_CASE(*test_suite->cur_test_case)
#define GET_CUR_TEST_BODY()             GET_CUR_TEST_SUITE()->test_body

#define GEN_TEST_SUITE_BEGIN(test_suite_name)\
    fprintf(test_mms_file, TEST_SUITE_PREFIX_FORMAT, test_suite_name);\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":BLANK_STR");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":TEST_SUITE_STR");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, "suite_name");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":NEW_LINE");\
    fprintf(test_mms_file, "\n");
#define GEN_TEST_SUITE_END(test_suite_name)\
    fprintf(test_mms_file, TEST_SUITE_PREFIX_FORMAT, test_suite_name);\
    fprintf(test_mms_file, PRINT_RESULT_FORMAT, ":suite_result", ":suite_result");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":TEST_SUITE_STR");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, "suite_name");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":NEW_LINE");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":NEW_LINE");\
    fprintf(test_mms_file, "%s", PREFIX_END);\
    fprintf(test_mms_file, "\n");
#define GEN_TEST_CASE_BEGIN(test_suite_name, test_case_name)\
    fprintf(test_mms_file, TEST_CASE_PREFIX_FORMAT, test_suite_name, test_case_name);
#define GEN_TEST_CASE_END()\
    fprintf(test_mms_file, "%s", AFTER_ASSERTION_CALL_FORMAT);\
    fprintf(test_mms_file, PRINT_RESULT_FORMAT, ":case_result", ":case_result");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":TEST_CASE_STR");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, "case_name");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":NEW_LINE");\
    fprintf(test_mms_file, "\n");
#define GEN_TEST_END()\
    fprintf(test_mms_file, PRINT_RESULT_FORMAT, ":test_result", ":test_result");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":TEST_ALL_STR");\
    fprintf(test_mms_file, PRINT_STR_FORMAT, ":NEW_LINE");

static char* str_rm_suffix(const char* src, char* dest, size_t len)
{
    size_t cur_len = 0;
    char* cur = dest;
    while (*src && *src != '.' && ++cur_len < len)
        *cur++ = *src++;
    *cur = '\0';
    return dest;
}

static bool get_cur_bin_path(char bin_path[PATH_MAX])
{
    ssize_t size = readlink("/proc/self/exe", bin_path, PATH_MAX - 1);
    if (size == -1)
        return false;
    bin_path[PATH_MAX - 1] = '\0';
    return true;
}

static char* get_dir_name(const char* path, char dir[PATH_MAX])
{
    char* last_slash_pos = NULL;
    char* cur = dir;
    while (*path)
    {
        if (*path == '/')
            last_slash_pos = cur;
        *cur++ = *path++;
    }

    if (last_slash_pos)
        *last_slash_pos = '\0';
    else
        dir[0] = '.', dir[1] = '\0';
    return dir;
}

static char* get_dir_name_self(char path[PATH_MAX])
{
    char* last_slash_pos = NULL;
    char* cur = path;
    while (*cur)
    {
        if (*cur == '/')
            last_slash_pos = cur;
        cur++;
    }

    if (last_slash_pos)
        *last_slash_pos = '\0';
    return path;
}

static off_t get_file_size(FILE* file)
{
    int fd = fileno(file);
    struct stat fs;
    if (fstat(fd, &fs) == -1)
        return -1;

    return fs.st_size;
}

static void process_error(const char* msg, ...)
{
    va_list ap;
    va_start(ap, msg);
    vfprintf(stderr, msg, ap);
    va_end(ap);
    exit(EXIT_FAILURE);
}

static void check_context(test_label_t test_label, int line)
{
    test_label_t context_label;
    switch (test_label)
    {
    case TEST_TARGET:
    case TEST_SUITE_BEGIN:
        context_label = TEST_NULL;
        break;
    case TEST_SUITE_END:
        context_label = TEST_SUITE_BEGIN;
        break;
    case TEST_CASE_BEGIN:
        context_label = TEST_SUITE_BEGIN;
        break;
    case TEST_CASE_END:
        context_label = TEST_SUITE_BEGIN | TEST_CASE_BEGIN;
        break;
    case TEST_BODY_BEGIN:
        context_label = TEST_SUITE_BEGIN;
        break;
    case TEST_BODY_END:
        context_label = TEST_SUITE_BEGIN | TEST_BODY_BEGIN;
        break;
    case ASSERTION:
        context_label = TEST_SUITE_BEGIN | TEST_BODY_BEGIN;
        break;
    default:
        abort();
    }

    if (_context_label_ != context_label)
    {
        process_error("context error[line %d]: current_context[%u] != expected_context[%u]\n",
                line,  _context_label_, context_label);
    }
}

static void* zmalloc(size_t size)
{
    void* mem = malloc(size);
    if (!mem)
        process_error("malloc(%u): %m", size);
    return mem;
}

static const void* list_find(const linked_node_t *node, const char* name)
{
    LIST_FOREACH(node)
    {
        if (strcmp(GET_TEST_NAME(node->data), name) == 0)
            return node->data;
    }
    LIST_FOREACH_END(node);
    return NULL;
}

static linked_node_t* create_linked_node(void* data)
{
    linked_node_t *node = zmalloc(sizeof(linked_node_t));
    node->data = data;
    node->next = NULL;
    return node;
}

static void list_add(linked_node_t ***cur_node, const void* data)
{
    linked_node_t *new_node = create_linked_node((void*)data);
    **cur_node = new_node;
    *cur_node = &new_node->next;
}

static void* get_test_label_name(test_label_t test_label)
{
    switch (test_label)
    {
    case TEST_NULL:
        return "TEST_NULL";
    case TEST_TARGET:
        return "TEST_TARGET";
    case TEST_SUITE_BEGIN:
        return "TEST_SUITE";
    case TEST_BODY_BEGIN:
        return "TEST_BODY";
    case TEST_CASE_BEGIN:
        return "TEST_CASE";
    default:
        abort();
    }
}

static void check_duplicated(test_label_t test_label, const linked_node_t *head, const char* name)
{
    const void* test = list_find(head, name);
    if (test)
    {
        const char* test_label_name = get_test_label_name(test_label);
        const char* name = GET_TEST_NAME(test);
        int line = GET_TEST_LINE(test);
        process_error("[%s %s:%d] already exists\n", test_label_name, name, line);
    }
}

static void check_test_body_duplicated(const test_suite_t *test_suite)
{
    const test_body_t *test_body = test_suite->test_body;
    if (test_body)
    {
        process_error("[TEST_BODY:%d of TEST_SUITE:%s:%d] already exists",
                test_body->line, test_suite->name, test_suite->line);
    }
}

static const char* get_key(const char* text)
{
    const char* begin = text + ESC_LEN;
    char* end = strchr(begin, ' ');
    size_t len = end - begin;
    char* key = (char*)zmalloc(len + 1);
    strncpy(key, begin, len);
    key[len] = '\0';
    return key;
}

static char* get_param_list(const char* text)
{
    const char* space = strrchr(text, ' ');
    const char* begin = space + 1;
    const char* end = strchr(begin, ']');
    size_t len = end - begin;
    char* param_list = (char*)zmalloc(len + 1);
    strncpy(param_list, begin, len);
    param_list[len] = '\0';
    return param_list;
}

static const test_target_t* create_test_target(const char* name, int line)
{
    test_target_t *test_target = (test_target_t*)zmalloc(sizeof(test_target_t));
    test_target->name = name;
    test_target->line = line;
    return test_target;
}

static void add_test_target(const char* name, int line)
{
    const test_target_t *test_target = create_test_target(name, line);
    list_add(&_cur_test_target_, test_target);
}

static void test_target(const char* text, int line)
{
    check_context(TEST_TARGET, line);

    const char* name = get_param_list(text);
    check_duplicated(TEST_TARGET, _test_target_head_, name);
    add_test_target(name, line);
}

static test_suite_t* create_test_suite(const char* name, int line)
{
    test_suite_t *test_suite = (test_suite_t*)zmalloc(sizeof(test_suite_t));
    test_suite->name = name;
    test_suite->line = line;
    test_suite->test_body = NULL;
    test_suite->cur_test_case = &test_suite->test_case_head;
    return test_suite;
}

static void add_test_suite(const char* name, int line)
{
    test_suite_t *test_suite = create_test_suite(name, line);
    *_cur_test_suite_ = create_linked_node(test_suite);
}

static void test_suite_begin(const char* text, int line)
{
    check_context(TEST_SUITE_BEGIN, line);
    ADD_CONTEXT_LABEL(TEST_SUITE_BEGIN);

    const char* name = get_param_list(text);
    check_duplicated(TEST_SUITE_BEGIN, _test_suite_head_, name);
    add_test_suite(name, line);
}

static void test_suite_end(void)
{
    LIST_FORWARD(_cur_test_suite_);
    RM_CONTEXT_LABEL(TEST_SUITE_BEGIN);
}

static test_case_t* create_test_case(const char* name, int line, const char* test_case_begin)
{
    test_case_t *test_case = (test_case_t*)zmalloc(sizeof(test_case_t));
    test_case->name = name;
    test_case->line = line;
    test_case->code.begin = test_case_begin + strlen(test_case_begin);
    return test_case;
}

static void add_test_case(const char* name, int line, const char* text)
{
    test_case_t *test_case = create_test_case(name, line, text);
    test_suite_t *test_suite = GET_CUR_TEST_SUITE();
    *test_suite->cur_test_case = create_linked_node(test_case);
}

static void test_case_begin(const char* text, int line)
{
    check_context(TEST_CASE_BEGIN, line);
    ADD_CONTEXT_LABEL(TEST_CASE_BEGIN);

    const char* name = get_param_list(text);
    test_suite_t *test_suite = GET_CUR_TEST_SUITE();
    check_duplicated(TEST_CASE_BEGIN, test_suite->test_case_head, name);
    add_test_case(name, line, text);
}

static void test_case_end(const char* text)
{
    test_suite_t *test_suite = GET_CUR_TEST_SUITE();
    test_case_t *test_case = GET_CUR_TEST_CASE(test_suite);
    test_case->code.end = text - 1;
    LIST_FORWARD(test_suite->cur_test_case);
    RM_CONTEXT_LABEL(TEST_CASE_BEGIN);
}

static test_body_t* create_test_body(const char* text, int line)
{
    test_body_t *test_body = (test_body_t*)zmalloc(sizeof(test_body_t));
    test_body->line = line;
    test_body->prev_text = text + strlen(text);
    test_body->cur_code = &test_body->code_head;
    return test_body;
}

static void test_body_begin(const char* text, int line)
{
    check_context(TEST_BODY_BEGIN, line);
    ADD_CONTEXT_LABEL(TEST_BODY_BEGIN);

    test_suite_t *test_suite = GET_CUR_TEST_SUITE();
    check_test_body_duplicated(test_suite);
    test_suite->test_body = create_test_body(text, line);
}

static bool has_code(const char* begin, const char* end)
{
    while (begin <= end)
    {
        if (!isspace(*begin) && *begin != '\n')
            return true;
        begin++;
    }
    return false;
}

static const code_t* create_code_code_block(const char* begin, const char* end)
{
    while (*end != '\n' && isspace(*end))
        end--;

    code_t *code = (code_t*)zmalloc(sizeof(code_t));
    code->code_type = CODE_BLOCK;
    code->code_block.begin = begin;
    code->code_block.end = end;
    return code;
}

static void add_code_code_block(test_body_t *test_body, const char* end)
{
    const code_t *code = create_code_code_block(test_body->prev_text, end);
    list_add(&test_body->cur_code, code);
}

static void try_add_code_block_for_test_body(const char* text)
{
    test_body_t *test_body = GET_CUR_TEST_BODY();
    if (has_code(test_body->prev_text, text - 1))
        add_code_code_block(test_body, text - 1);
    test_body->prev_text = text + strlen(text);
}

static void test_body_end(const char* text)
{
    try_add_code_block_for_test_body(text);
    RM_CONTEXT_LABEL(TEST_BODY_BEGIN);
}

static const assertion_t* create_assertion(const char* name)
{
    assertion_t *assertion = (assertion_t*)zmalloc(sizeof(assertion_t));
    assertion->name = name;
    return assertion;
}

static const assertion_t* get_or_create_assertion(const char* assertion_begin)
{
    const char* name = get_key(assertion_begin);
    const assertion_t *assertion = list_find(_assertion_head_, name);
    if (!assertion)
    {
        assertion = create_assertion(name);
        list_add(&_cur_assertion_, assertion);
    }
    else
    {
        free((char*)name);
    }
    return assertion;
}

static const code_t* create_code_assertion_call(const assertion_t *assertion, const char* assertion_begin)
{
    char* param_list = get_param_list(assertion_begin);
    code_t *code = (code_t*)zmalloc(sizeof(code_t));
    code->code_type = ASSERTION_CALL;
    code->assertion_call.name = assertion->name;
    code->assertion_call.param_list = param_list;
    return code;
}

static void add_code_assertion_call(const assertion_t *assertion, const char* assertion_begin)
{
    const code_t *code = create_code_assertion_call(assertion, assertion_begin);
    list_add(&GET_CUR_TEST_BODY()->cur_code, code);
}

static void add_assertion_call_for_test_body(const char* assertion_begin)
{
    const assertion_t *assertion = get_or_create_assertion(assertion_begin);
    add_code_assertion_call(assertion, assertion_begin);
}

static void assertion(const char* text, int line)
{
    check_context(ASSERTION, line);
    try_add_code_block_for_test_body(text);
    add_assertion_call_for_test_body(text);

    GET_CUR_TEST_BODY()->prev_text = text + strlen(text);
}

#ifdef DEBUG
static void debug(const char* test_mmt_file_name)
{
    printf("%s\n", test_mmt_file_name);

    printf("----------test_target begin----------\n");
    linked_node_t *test_target_node = _test_target_head_;
    LIST_FOREACH(test_target_node)
    {
        test_target_t *test_target = GET_TEST_TARGET(test_target_node);
        printf("%s:%d\n", test_target->name, test_target->line);
    }
    LIST_FOREACH_END(test_target_node);
    printf("----------test_target end----------\n\n");

    printf("----------test_suite begin----------\n");
    linked_node_t *test_suite_node = _test_suite_head_;
    LIST_FOREACH(test_suite_node)
    {
        test_suite_t *test_suite = GET_TEST_SUITE(test_suite_node);
        printf("%s:%d\n", test_suite->name, test_suite->line);

        test_body_t *test_body = test_suite->test_body;
        printf("----------test_body begin----------\n");
        printf("%d\n", test_body->line);
        linked_node_t *code_node = test_body->code_head;
        LIST_FOREACH(code_node)
        {
            code_t *code = GET_CODE(code_node);
            if (code->code_type == CODE_BLOCK)
            {
                printf("-----code_block begin-----\n");
                fwrite(code->code_block.begin, 1, code->code_block.end - code->code_block.begin + 1, stdout);
                printf("-----code_block end-----\n");
            }
            else
            {
                printf("-----assertion begin-----\n");
                printf("%s %s\n", code->assertion_call.name, code->assertion_call.param_list);
                printf("-----assertion end-----\n");
            }
        }
        LIST_FOREACH_END(code_node);
        printf("----------test_body end----------\n\n");

        printf("----------test_case begin----------\n");
        linked_node_t *test_case_node = test_suite->test_case_head;
        LIST_FOREACH(test_case_node)
        {
            test_case_t *test_case = GET_TEST_CASE(test_case_node);
            printf("%s:%d\n", test_case->name, test_case->line);
            fwrite(test_case->code.begin, 1, test_case->code.end - test_case->code.begin + 1, stdout);
        }
        LIST_FOREACH_END(test_case_node);
        printf("----------test_case end----------\n");
    }
    LIST_FOREACH_END(test_suite_node);
    printf("----------test_suite end----------\n");
}
#endif

static void get_test_mms_file_name(const char* mmt, char mms[PATH_MAX])
{
    int len = snprintf(mms, PATH_MAX, "%s", mmt);
    mms[len - 1] = 's';
}

static void generate_data_segment(FILE* test_mms_file, const linked_node_t *test_suite_node)
{
    fprintf(test_mms_file, "%s", DATA_SEGMENT_HEAD);

    LIST_FOREACH(test_suite_node)
    {
        const test_suite_t *test_suite = GET_TEST_SUITE(test_suite_node);
        const char* test_suite_name = test_suite->name;
        fprintf(test_mms_file, TEST_SUITE_PREFIX_FORMAT, test_suite_name);
        fprintf(test_mms_file, "%s", GREG_BASE_ADDR);
        fprintf(test_mms_file, TEST_SUITE_NAME_FORMAT, test_suite_name);

        const linked_node_t *test_case_node = test_suite->test_case_head;
        LIST_FOREACH(test_case_node)
        {
            const test_case_t *test_case = GET_TEST_CASE(test_case_node);
            fprintf(test_mms_file, TEST_CASE_PREFIX_FORMAT, test_suite_name, test_case->name);
            fprintf(test_mms_file, "%s", GREG_BASE_ADDR);
            fprintf(test_mms_file, TEST_CASE_NAME_FORMAT, test_case->name);
            const code_block_t *code = &test_case->code;
            fwrite(code->begin, 1, code->end - code->begin + 1, test_mms_file);
            fprintf(test_mms_file, "\n");
        }
        LIST_FOREACH_END(test_case_node);
    }
    LIST_FOREACH_END(test_suite_node);

    fprintf(test_mms_file, "%s\n", PREFIX_END);
}

static void get_file_buffer(const char* file_name, code_buffer_t *file_buffer)
{
    FILE* file = fopen(file_name, "r");
    if (!file)
        process_error("fopen(%s, \"r\") error: %m\n", file_name);

    off_t size = get_file_size(file);
    if (size == -1)
        process_error("get_file_size(%s) error", file_name);

    file_buffer->buf = zmalloc(size);
    file_buffer->size = size;
    fread(file_buffer->buf, 1, size, file);
    fclose(file);
}

static void include_mms(FILE* test_mms_file, const char* dir, const char* file)
{
    char mms_file[PATH_MAX];
    snprintf(mms_file, PATH_MAX, "%s/%s.mms", dir, file);

    code_buffer_t file_buffer;
    get_file_buffer(mms_file, &file_buffer);
    fwrite(file_buffer.buf, 1, file_buffer.size, test_mms_file);
    fprintf(test_mms_file, "\n");
    free(file_buffer.buf);
}

static void include_builtin_lib(FILE* test_mms_file, const char* zlibmmix_path)
{
    char builtin_mms_path[PATH_MAX];
    snprintf(builtin_mms_path, PATH_MAX, "%s/%s", zlibmmix_path, BUILTIN_MMS);
    FILE* builtin_mms_file = fopen(builtin_mms_path, "r");
    if (!builtin_mms_file)
        process_error("fopen(%s, \"r\") error:%m", builtin_mms_path);

    char builtin_mms[PATH_MAX];
    while (fgets(builtin_mms, PATH_MAX, builtin_mms_file))
    {
        builtin_mms[strlen(builtin_mms) - 1] = '\0';
        include_mms(test_mms_file, zlibmmix_path, builtin_mms);
    }

    fclose(builtin_mms_file);
}

static void generate_test_target(FILE* test_mms_file, const linked_node_t *test_target_node)
{
    LIST_FOREACH(test_target_node)
    {
        test_target_t *test_target = GET_TEST_TARGET(test_target_node);
        include_mms(test_mms_file, _test_dir_, test_target->name);
    }
    LIST_FOREACH_END(test_target_node);
}

static void get_zlibmmix_path(char zlibmmix_path[PATH_MAX])
{
    char tester_bin_path[PATH_MAX];
    if (!get_cur_bin_path(tester_bin_path))
        process_error("get_cur_bin_path() error");

    get_dir_name_self(tester_bin_path);
    get_dir_name_self(tester_bin_path);
    snprintf(zlibmmix_path, PATH_MAX, "%s/lib/%s", tester_bin_path, ZLIB_MMIX);
}

static void generate_assertion(FILE* test_mms_file, const linked_node_t *assertion_node, const char* zlibmmix_path)
{
    char assertion_dir[PATH_MAX];
    snprintf(assertion_dir, PATH_MAX, "%s/%s", zlibmmix_path, ASSERTION_DIR);
    LIST_FOREACH(assertion_node)
    {
        assertion_t *assertion = GET_ASSERTION(assertion_node);
        include_mms(test_mms_file, assertion_dir, assertion->name);
    }
    LIST_FOREACH_END(assertion_node);
}

static int get_param_count(const char* param_list)
{
    int count = 0;
    while (*param_list)
    {
        if (*param_list == ',')
            count++;
        param_list++;
    }
    return count + 1;
}

static size_t get_test_body_buffer_size(const test_body_t *test_body)
{
    size_t lda_len = strlen(ASSERTION_LDA_FORMAT) - ASSERTION_LDA_FORMAT_LEN_DIFF;
    size_t assertion_call_len = strlen(ASSERTION_PUSHJ_FORMAT) - ASSERTION_PUSHJ_FORMAT_LEN_DIFF;

    size_t size = 0;
    const linked_node_t *code_node = test_body->code_head;
    LIST_FOREACH(code_node)
    {
        const code_t *code = GET_CODE(code_node);
        if (code->code_type == CODE_BLOCK)
        {
            const code_block_t *code_block = GET_CODE_BLOCK(code);
            size += code_block->end - code_block->begin + 1;
        }
        else
        {
            const assertion_call_t* assertion_call = GET_ASSERTION_CALL(code);
            int param_count = get_param_count(assertion_call->param_list);
            size += param_count * lda_len + strlen(assertion_call->param_list) - param_count + 1
                    + assertion_call_len + strlen(assertion_call->name);
        }
    }
    LIST_FOREACH_END(code_node);

    return size;
}

static void get_test_body_buffer(const test_body_t *test_body, code_buffer_t *test_body_buffer)
{
    size_t size = get_test_body_buffer_size(test_body);
    char* buf = (char*)zmalloc(size + 1);   /* Because of using sprintf(), it must be one byte more for '\0' */
    char* cur = buf;

    const linked_node_t *code_node = test_body->code_head;
    LIST_FOREACH(code_node)
    {
        const code_t *code = GET_CODE(code_node);
        if (code->code_type == CODE_BLOCK)
        {
            const code_block_t *code_block = GET_CODE_BLOCK(code);
            size_t size = code_block->end - code_block->begin + 1;
            strncpy(cur, code_block->begin, size);
            cur += size;
        }
        else
        {
            const assertion_call_t* assertion_call = GET_ASSERTION_CALL(code);
            const char* param = strtok(assertion_call->param_list, ",");
            int reg = 1;
            while (param)
            {
                int num = sprintf(cur, ASSERTION_LDA_FORMAT, reg, param);
                cur += num;
                param = strtok(NULL, ",");
                reg++;
            }
            int num = sprintf(cur, ASSERTION_PUSHJ_FORMAT, assertion_call->name);
            cur += num;
        }
    }
    LIST_FOREACH_END(code_node);

    test_body_buffer->buf = buf;
    test_body_buffer->size = size;
}

static void generate_test_suite(FILE* test_mms_file, const linked_node_t *test_suite_node)
{
    fprintf(test_mms_file, "%s", MAIN_HEAD);

    LIST_FOREACH(test_suite_node)
    {
        const test_suite_t *test_suite = GET_TEST_SUITE(test_suite_node);
        const char* test_suite_name = test_suite->name;
        GEN_TEST_SUITE_BEGIN(test_suite_name);

        code_buffer_t test_body_buffer;
        get_test_body_buffer(test_suite->test_body, &test_body_buffer);

        const linked_node_t *test_case_node = test_suite->test_case_head;
        LIST_FOREACH(test_case_node)
        {
            const test_case_t *test_case = GET_TEST_CASE(test_case_node);
            GEN_TEST_CASE_BEGIN(test_suite_name, test_case->name);
            fwrite(test_body_buffer.buf, 1, test_body_buffer.size, test_mms_file);
            GEN_TEST_CASE_END();
        }
        LIST_FOREACH_END(test_case_node);

        GEN_TEST_SUITE_END(test_suite_name);
        free(test_body_buffer.buf);
    }
    LIST_FOREACH_END(test_suite_node);

    GEN_TEST_END();
}

static void generate_text_segment(FILE* test_mms_file, const linked_node_t *test_target_node,
                                  const linked_node_t *assertion_node, const linked_node_t *test_suite_node)
{
    char zlibmmix_path[PATH_MAX];
    get_zlibmmix_path(zlibmmix_path);

    fprintf(test_mms_file, "%s", TEXT_SEGMENT_HEAD);
    include_builtin_lib(test_mms_file, zlibmmix_path);
    generate_test_target(test_mms_file, test_target_node);
    generate_assertion(test_mms_file, assertion_node, zlibmmix_path);
    generate_test_suite(test_mms_file, test_suite_node);
}

static void generate_test_mms_file(const char* test_mmt_file_name)
{
#ifdef DEBUG
    debug(test_mmt_file_name);
#endif

    char test_mms_file_name[PATH_MAX];
    get_test_mms_file_name(test_mmt_file_name, test_mms_file_name);

    FILE* test_mms_file = fopen(test_mms_file_name, "w");
    if (!test_mms_file)
        process_error("fopen(%s, \"w\") error: %m\n", test_mms_file_name);

    generate_data_segment(test_mms_file, _test_suite_head_);
    generate_text_segment(test_mms_file, _test_target_head_, _assertion_head_, _test_suite_head_);
    fclose(test_mms_file);
}
%}

SP          [[:blank:]]
ESC         \[
CSE         \]
UPPER_SYM   [_A-Z]
SYM         [_:A-Za-z0-9]
COMMENT     (\/\*([^*]|\*+[^/*])*\*+\/)|("//".*\n)

%option yylineno

%%
.
\n
{COMMENT}
{ESC}TEST_TARGET{SP}+{SYM}+{CSE}\n                      {test_target(yytext, yylineno - 1);}
{ESC}TEST_SUITE{SP}+{SYM}+{CSE}\n                       {test_suite_begin(yytext, yylineno - 1);}
{ESC}TEST_SUITE_END{CSE}\n                              {test_suite_end();}
{ESC}TEST_CASE{SP}+{SYM}+{CSE}\n                        {test_case_begin(yytext, yylineno - 1);}
{ESC}TEST_CASE_END{CSE}\n                               {test_case_end(yytext);}
{ESC}TEST_BODY{CSE}\n                                   {test_body_begin(yytext, yylineno - 1);}
{ESC}TEST_BODY_END{CSE}\n                               {test_body_end(yytext);}
{ESC}ASSERT_{UPPER_SYM}+{SP}+{SYM}+(,{SYM}+)*{CSE}\n    {assertion(yytext, yylineno - 1);}
{ESC}.*{CSE}.*                                          {process_error("label error: %s$\n", yytext);}
<<EOF>>                                                 {generate_test_mms_file(TEST_MMT_FILE_NAME); yyterminate();}
%%

static void usage(void)
{
    char tester_bin_name[PATH_MAX];
    str_rm_suffix(__FILE__, tester_bin_name, PATH_MAX);
    process_error("Usage: %s TEST_FILE\n", tester_bin_name);
}

static void free_test_target(const linked_node_t* test_target_node)
{
    while (test_target_node)
    {
        const test_target_t *test_target = GET_TEST_TARGET(test_target_node);
        free((void*)test_target->name);
        free((void*)test_target);

        const linked_node_t* cur_test_target_node = test_target_node;
        test_target_node = test_target_node->next;
        free((void*)cur_test_target_node);
    }
}

static void free_test_body(test_body_t *test_body)
{
    const linked_node_t* code_node = test_body->code_head;
    while (code_node)
    {
        const code_t *code = GET_CODE(code_node);
        if (code->code_type == ASSERTION_CALL)
        {
            const assertion_call_t *assertion_call = GET_ASSERTION_CALL(code);
            free((void*)assertion_call->name);
            free(assertion_call->param_list);
        }
        free((void*)code);

        const linked_node_t* cur_code_node = code_node;
        code_node = code_node->next;
        free((void*)cur_code_node);
    }
}

static void free_test_case(const linked_node_t* test_case_node)
{
    while (test_case_node)
    {
        const test_case_t *test_case = GET_TEST_CASE(test_case_node);
        free((void*)test_case->name);
        free((void*)test_case);

        const linked_node_t* cur_test_case_node = test_case_node;
        test_case_node = test_case_node->next;
        free((void*)cur_test_case_node);
    }
}

static void free_test_suite(const linked_node_t* test_suite_node)
{
    while (test_suite_node)
    {
        const test_suite_t *test_suite = GET_TEST_SUITE(test_suite_node);
        free_test_body(test_suite->test_body);
        free_test_case(test_suite->test_case_head);
        free((void*)test_suite->name);
        free(test_suite->test_body);
        free((void*)test_suite);

        const linked_node_t* cur_test_suite_node = test_suite_node;
        test_suite_node = test_suite_node->next;
        free((void*)cur_test_suite_node);
    }
}

static void free_asssertion(const linked_node_t* assertion_node)
{
    while (assertion_node)
    {
        const assertion_t *assertion = GET_ASSERTION(assertion_node);
        free((void*)assertion->name);
        free((void*)assertion);

        const linked_node_t* cur_assertion_node = assertion_node;
        assertion_node = assertion_node->next;
        free((void*)cur_assertion_node);
    }
}

static void free_res(void)
{
    free_test_target(_test_target_head_);
    free_test_suite(_test_suite_head_);
    free_asssertion(_assertion_head_);
}

static void compile(const char* test_file_name)
{
    TEST_MMT_FILE_NAME = test_file_name;
    get_dir_name(test_file_name, _test_dir_);

    FILE* test_file = fopen(test_file_name, "r");
    if (!test_file)
        process_error("fopen(%s, \"r\") error: %m\n", test_file_name);

    off_t file_size = get_file_size(test_file);
    if (file_size == -1)
        process_error("get_file_size(%s) error", test_file_name);

    YY_BUFFER_STATE file_buffer = yy_create_buffer(test_file, file_size);
    yy_switch_to_buffer(file_buffer);
    yylex();
    yy_delete_buffer(file_buffer);

    fclose(test_file);
    free_res();
}

int main(int argc, char* argv[])
{
    if (argc < 2)
        usage();

    compile(argv[1]);
    return EXIT_SUCCESS;
}
