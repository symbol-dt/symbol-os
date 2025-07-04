#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#define lenof(x) (sizeof(x)/sizeof(*x))
bool debug = false;
int platform = 0;

const char *platforms[] = {
    "amd64", "aarch64", 
};
const char init_makefile[] =
"configure: src/configure.c\n"\
"\t@ $(CC) -o configure src/configure.c\n"\
"\t@ ./configure\n";

void strlwr(char *str){
    for(int i = 0; str[i] != '\0'; i++)
        str[i] = tolower(str[i]);
}

int main (int argc, char *argv[]) {
    char name[1024], value[1024], line[2048];
    FILE *makefile = NULL;
    int i;

    makefile = fopen("Makefile", "w");
    if(makefile == NULL){
        printf("Error: Could not create Makefile\n");
        return 1; 
    }
    if(argc > 1){
        if(strcmp(argv[1], "--init") == 0) {
            fputs(init_makefile, makefile);
            fclose(makefile);
            return 0;
        }
        if(freopen(argv[1], "r", stdin) == NULL){
            printf("Error: File %s not found\n", argv[1]);
            return 1;
        }
        while(fgets(line, sizeof(line), stdin) != NULL){
            if(sscanf(line, "%s = %s", name, value) == 2){
                strlwr(name);
                if(strcmp(name, "debug") == 0){
                   strlwr(value);
                   if(strcmp(value, "true") == 0) debug = true;
                    else if(strcmp(value, "false") == 0) debug = false;
                    else printf("Error: Invalid value for debug\n");
                } else if(strcmp(name, "platform") == 0){
                    strlwr(value);
                    for(i = 0; i < lenof(platforms); i++){
                        if(strcmp(value, platforms[i]) == 0){
                            platform = i;
                            break;
                        }
                    }
                    if(platform == lenof(platforms)) printf("Error: Invalid platform\n");
                } else printf("Error: Invalid variable %s\n", name);
            }
        }
    } else {
        ask_debug:
        printf("Debug (true/false): ");
        scanf("%s", value);
        strlwr(value);
        if(strcmp(value, "true") == 0) debug = true;
        else if(strcmp(value, "false") == 0) debug = false;
        else {
            printf("Error: Invalid value for debug\n");
            goto ask_debug;
        }

        ask_platform:
        printf("Platform (amd64/aarch64): ");
        scanf("%s", value);
        strlwr(value);
        for(i = 0; i < lenof(platforms); i++){
            if(strcmp(value, platforms[i]) == 0){
                platform = i;
                break;
            }
        }
        if(i == lenof(platforms)) {
            printf("Error: Invalid platform\n");
            goto ask_platform;
        }
    }

    fprintf(makefile, "project_path := $(CURDIR)\n");

    fputs("", makefile);

    fprintf(makefile, "all: clean\n");
    fprintf(makefile, "\t@ $(MAKE) -C $(project_path)/src "
        "\"project_path=$(project_path)\" "
        "\"debug=%s\" "
        "\"platform=%s\"\n",
        debug ? "true" : "false",
        platforms[platform]);

    fputs("", makefile);

    fprintf(makefile, "clean: *\n");
    fprintf(makefile, "ifeq ($(wildcard $(project_path)/bin), )\n");
#if defined(__linux__)
    fprintf(makefile, "\t@ mkdir -p $(project_path)/bin\n");
#elif defined(_WIN32)
    fprintf(makefile, "\t- mkdir $(project_path)/bin\n");
#endif
    fprintf(makefile, "else\n");
#if defined(__linux__)
    fprintf(makefile, "\t@ rm -rf $(project_path)/bin/*\n");
#elif defined(_WIN32)
    fprintf(makefile, "\t@ rmdir /s /q $(project_path)/bin\n");
    fprintf(makefile, "\t@ mkdir $(project_path)/bin\n");
#endif
    fprintf(makefile, "endif\n");

    fputs("", makefile);

    fprintf(makefile, "configure: src/configure.c\n");
    fprintf(makefile, "\t@ $(CC) -o configure src/configure.c\n");
    fprintf(makefile, "\t@ ./configure\n");
    return 0;
}