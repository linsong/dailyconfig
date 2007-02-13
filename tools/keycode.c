/* the following code comes from http://groups.yahoo.com/group/vim/message/66414
 * compiling it with: $ gcc -o keycode oneliner.c
 * within Vim, do ":!keycode"
 * and test by hitting the key combinations
 * 
*/
main() {int c; while (c = getchar()) printf("%d 0x%02X\n", c, c);}
