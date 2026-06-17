#include "fs.h"
#include "io.h"
#include "str.h"

#define FS_MAX_NODES 64
#define FS_NAME_MAX 16

typedef struct {
    char name[FS_NAME_MAX];
    unsigned char used;
    unsigned char is_dir;
    int parent;
    int first_child;
    int next_sibling;
    const char *content;
} fs_node;

static fs_node nodes[FS_MAX_NODES];
static int root;
static int cwd;

static int alloc_node(void) {
    for (int i = 0; i < FS_MAX_NODES; i++)
        if (!nodes[i].used)
            return i;
    return -1;
}

static int new_node(int parent, const char *name, int is_dir,
                    const char *content) {
    int n = alloc_node();
    if (n < 0)
        return -1;
    fs_node *p = &nodes[n];
    str_copy(p->name, name, FS_NAME_MAX);
    p->used = 1;
    p->is_dir = (unsigned char)is_dir;
    p->parent = parent;
    p->first_child = -1;
    p->next_sibling = -1;
    p->content = content;
    if (parent >= 0) {
        p->next_sibling = nodes[parent].first_child;
        nodes[parent].first_child = n;
    }
    return n;
}

static void unlink_node(int n) {
    int parent = nodes[n].parent;
    int *link = &nodes[parent].first_child;
    while (*link != -1 && *link != n)
        link = &nodes[*link].next_sibling;
    if (*link == n)
        *link = nodes[n].next_sibling;
    nodes[n].used = 0;
}

static int find_child(int dir, const char *name, int len) {
    for (int c = nodes[dir].first_child; c != -1; c = nodes[c].next_sibling) {
        int i = 0;
        while (i < len && nodes[c].name[i] == name[i])
            i++;
        if (i == len && nodes[c].name[i] == '\0')
            return c;
    }
    return -1;
}

// Resolve an existing path to a node index, or -1.
static int fs_resolve(const char *path) {
    int cur = (path[0] == '/') ? root : cwd;
    const char *p = path;
    while (*p) {
        while (*p == '/')
            p++;
        if (!*p)
            break;
        const char *start = p;
        while (*p && *p != '/')
            p++;
        int len = (int)(p - start);
        if (len == 1 && start[0] == '.')
            continue;
        if (len == 2 && start[0] == '.' && start[1] == '.') {
            cur = nodes[cur].parent < 0 ? cur : nodes[cur].parent;
            continue;
        }
        if (!nodes[cur].is_dir)
            return -1;
        cur = find_child(cur, start, len);
        if (cur < 0)
            return -1;
    }
    return cur;
}

void cmd_pwd(const char *args) {
    (void)args;
    int stack[FS_MAX_NODES];
    int top = 0;
    for (int n = cwd; nodes[n].parent >= 0; n = nodes[n].parent)
        stack[top++] = n;
    if (top == 0) {
        println("/");
        return;
    }
    while (top > 0) {
        print("/", nodes[stack[--top]].name);
    }
    print_char('\n');
}

void cmd_cd(const char *args) {
    if (args[0] == '\0') {
        cwd = root;
        return;
    }
    int n = fs_resolve(args);
    if (n < 0 || !nodes[n].is_dir) {
        println("cd: no such directory");
        return;
    }
    cwd = n;
}

void cmd_ls(const char *args) {
    int dir = (args[0] == '\0') ? cwd : fs_resolve(args);
    if (dir < 0) {
        println("ls: not found");
        return;
    }
    if (!nodes[dir].is_dir) {
        println(nodes[dir].name);
        return;
    }
    for (int c = nodes[dir].first_child; c != -1; c = nodes[c].next_sibling) {
        print(nodes[c].name);
        if (nodes[c].is_dir)
            print_char('/');
        print_char('\n');
    }
}

void cmd_cat(const char *args) {
    int n = fs_resolve(args);
    if (n < 0) {
        println("cat: not found");
        return;
    }
    if (nodes[n].is_dir) {
        println("cat: is a directory");
        return;
    }
    if (nodes[n].content)
        print_str(nodes[n].content);
}

// Split path into parent dir index and leaf name; returns parent or -1.
static int split_parent(const char *path, const char **leaf) {
    const char *slash = 0;
    for (const char *p = path; *p; p++)
        if (*p == '/')
            slash = p;
    if (!slash) {
        *leaf = path;
        return cwd;
    }
    char buf[FS_NAME_MAX * 4];
    int len = (int)(slash - path);
    if (len == 0) {
        *leaf = slash + 1;
        return root;
    }
    if (len >= (int)sizeof buf)
        return -1;
    str_copy(buf, path, len + 1);
    *leaf = slash + 1;
    return fs_resolve(buf);
}

void cmd_mkdir(const char *args) {
    if (args[0] == '\0') {
        println("mkdir: missing name");
        return;
    }
    const char *leaf;
    int parent = split_parent(args, &leaf);
    int len = str_len(leaf);
    if (parent < 0 || !nodes[parent].is_dir) {
        println("mkdir: bad path");
        return;
    }
    if (len == 0 || len >= FS_NAME_MAX) {
        println("mkdir: bad name");
        return;
    }
    if (find_child(parent, leaf, len) >= 0) {
        println("mkdir: already exists");
        return;
    }
    if (new_node(parent, leaf, 1, 0) < 0)
        println("mkdir: no space");
}

void cmd_rm(const char *args) {
    int n = fs_resolve(args);
    if (n < 0) {
        println("rm: not found");
        return;
    }
    if (nodes[n].is_dir) {
        println("rm: is a directory");
        return;
    }
    unlink_node(n);
}

void cmd_rmdir(const char *args) {
    int n = fs_resolve(args);
    if (n < 0 || !nodes[n].is_dir) {
        println("rmdir: not a directory");
        return;
    }
    if (n == root || n == cwd) {
        println("rmdir: in use");
        return;
    }
    if (nodes[n].first_child != -1) {
        println("rmdir: not empty");
        return;
    }
    unlink_node(n);
}

void fs_init(void) {
    for (int i = 0; i < FS_MAX_NODES; i++)
        nodes[i].used = 0;
    root = new_node(-1, "/", 1, 0);
    cwd = root;
}
