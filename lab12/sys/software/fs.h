#ifndef FS_H
#define FS_H

void fs_init(void);

void cmd_cd(const char *args);
void cmd_ls(const char *args);
void cmd_cat(const char *args);
void cmd_mkdir(const char *args);
void cmd_rm(const char *args);
void cmd_rmdir(const char *args);
void cmd_pwd(const char *args);

const char *fs_read(const char *path);
int fs_write(const char *path, const char *data, int append);

#endif
