/***************************************/
/* Set to 1 to allow szip encoding.    */
/* Set to 0 to prohibit szip encoding. */
/***************************************/

#ifdef REMOVE_SZIP_ENCODER
int szip_allow_encoding = 0; 
static char * szip_endoder_status = "SZIP ENCODER DISABLED";
#else
int szip_allow_encoding = 1; 
static char * szip_endoder_status = "SZIP ENCODER ENABLED";
#endif
