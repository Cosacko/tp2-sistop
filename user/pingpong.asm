
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define SEM_PING 1
#define SEM_PONG 2

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
    if (argc != 2)
   8:	4789                	li	a5,2
   a:	02f50263          	beq	a0,a5,2e <main+0x2e>
   e:	ec26                	sd	s1,24(sp)
  10:	e84a                	sd	s2,16(sp)
  12:	e44e                	sd	s3,8(sp)
    {
        printf("ERROR: Must provide an argument\n");
  14:	00001517          	auipc	a0,0x1
  18:	8ec50513          	addi	a0,a0,-1812 # 900 <malloc+0x108>
  1c:	00000097          	auipc	ra,0x0
  20:	724080e7          	jalr	1828(ra) # 740 <printf>
        exit(EXIT_FAILURE);
  24:	557d                	li	a0,-1
  26:	00000097          	auipc	ra,0x0
  2a:	392080e7          	jalr	914(ra) # 3b8 <exit>
  2e:	ec26                	sd	s1,24(sp)
    }
    uint pingpong_n = atoi(argv[1]);
  30:	6588                	ld	a0,8(a1)
  32:	00000097          	auipc	ra,0x0
  36:	28c080e7          	jalr	652(ra) # 2be <atoi>
  3a:	84aa                	mv	s1,a0
    if (pingpong_n < 1)
  3c:	e105                	bnez	a0,5c <main+0x5c>
  3e:	e84a                	sd	s2,16(sp)
  40:	e44e                	sd	s3,8(sp)
    {
        printf("ERROR: The argument must be greater or equal than 1.\n");
  42:	00001517          	auipc	a0,0x1
  46:	8e650513          	addi	a0,a0,-1818 # 928 <malloc+0x130>
  4a:	00000097          	auipc	ra,0x0
  4e:	6f6080e7          	jalr	1782(ra) # 740 <printf>
        exit(EXIT_FAILURE);
  52:	557d                	li	a0,-1
  54:	00000097          	auipc	ra,0x0
  58:	364080e7          	jalr	868(ra) # 3b8 <exit>
  5c:	e84a                	sd	s2,16(sp)
    }

    sem_open(SEM_PING, 1);
  5e:	4585                	li	a1,1
  60:	4505                	li	a0,1
  62:	00000097          	auipc	ra,0x0
  66:	3f6080e7          	jalr	1014(ra) # 458 <sem_open>
    sem_open(SEM_PONG, 0);
  6a:	4581                	li	a1,0
  6c:	4509                	li	a0,2
  6e:	00000097          	auipc	ra,0x0
  72:	3ea080e7          	jalr	1002(ra) # 458 <sem_open>
    int pid;
    pid = fork();
  76:	00000097          	auipc	ra,0x0
  7a:	33a080e7          	jalr	826(ra) # 3b0 <fork>
  7e:	892a                	mv	s2,a0
    if (pid < 0)
  80:	02054f63          	bltz	a0,be <main+0xbe>
    {
        printf("ERROR: fork() failed\n");
        exit(EXIT_FAILURE);
    }    
    else if (pid == 0)
  84:	e939                	bnez	a0,da <main+0xda>
  86:	e44e                	sd	s3,8(sp)
    {
        for (int i = 0; i < pingpong_n; i++) 
        {
            sem_down(SEM_PONG); 
            printf("\tpong\n");
  88:	00001997          	auipc	s3,0x1
  8c:	8f098993          	addi	s3,s3,-1808 # 978 <malloc+0x180>
            sem_down(SEM_PONG); 
  90:	4509                	li	a0,2
  92:	00000097          	auipc	ra,0x0
  96:	3d6080e7          	jalr	982(ra) # 468 <sem_down>
            printf("\tpong\n");
  9a:	854e                	mv	a0,s3
  9c:	00000097          	auipc	ra,0x0
  a0:	6a4080e7          	jalr	1700(ra) # 740 <printf>
            sem_up(SEM_PING); 
  a4:	4505                	li	a0,1
  a6:	00000097          	auipc	ra,0x0
  aa:	3ca080e7          	jalr	970(ra) # 470 <sem_up>
        for (int i = 0; i < pingpong_n; i++) 
  ae:	2905                	addiw	s2,s2,1
  b0:	ff2490e3          	bne	s1,s2,90 <main+0x90>
        }
        exit(EXIT_SUCCESS);
  b4:	4501                	li	a0,0
  b6:	00000097          	auipc	ra,0x0
  ba:	302080e7          	jalr	770(ra) # 3b8 <exit>
  be:	e44e                	sd	s3,8(sp)
        printf("ERROR: fork() failed\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	8a050513          	addi	a0,a0,-1888 # 960 <malloc+0x168>
  c8:	00000097          	auipc	ra,0x0
  cc:	678080e7          	jalr	1656(ra) # 740 <printf>
        exit(EXIT_FAILURE);
  d0:	557d                	li	a0,-1
  d2:	00000097          	auipc	ra,0x0
  d6:	2e6080e7          	jalr	742(ra) # 3b8 <exit>
  da:	e44e                	sd	s3,8(sp)
    }
    else
    {

        for (int i = 0; i < pingpong_n; i++) 
  dc:	4901                	li	s2,0
        {
            sem_down(SEM_PING);
            printf("ping\n");
  de:	00001997          	auipc	s3,0x1
  e2:	8a298993          	addi	s3,s3,-1886 # 980 <malloc+0x188>
            sem_down(SEM_PING);
  e6:	4505                	li	a0,1
  e8:	00000097          	auipc	ra,0x0
  ec:	380080e7          	jalr	896(ra) # 468 <sem_down>
            printf("ping\n");
  f0:	854e                	mv	a0,s3
  f2:	00000097          	auipc	ra,0x0
  f6:	64e080e7          	jalr	1614(ra) # 740 <printf>
            sem_up(SEM_PONG);
  fa:	4509                	li	a0,2
  fc:	00000097          	auipc	ra,0x0
 100:	374080e7          	jalr	884(ra) # 470 <sem_up>
        for (int i = 0; i < pingpong_n; i++) 
 104:	2905                	addiw	s2,s2,1
 106:	ff2490e3          	bne	s1,s2,e6 <main+0xe6>
        }

        wait(0);
 10a:	4501                	li	a0,0
 10c:	00000097          	auipc	ra,0x0
 110:	2b4080e7          	jalr	692(ra) # 3c0 <wait>

        sem_close(SEM_PING);
 114:	4505                	li	a0,1
 116:	00000097          	auipc	ra,0x0
 11a:	34a080e7          	jalr	842(ra) # 460 <sem_close>
        sem_close(SEM_PONG);
 11e:	4509                	li	a0,2
 120:	00000097          	auipc	ra,0x0
 124:	340080e7          	jalr	832(ra) # 460 <sem_close>
    }

    exit(EXIT_SUCCESS);
 128:	4501                	li	a0,0
 12a:	00000097          	auipc	ra,0x0
 12e:	28e080e7          	jalr	654(ra) # 3b8 <exit>

0000000000000132 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 132:	1141                	addi	sp,sp,-16
 134:	e406                	sd	ra,8(sp)
 136:	e022                	sd	s0,0(sp)
 138:	0800                	addi	s0,sp,16
  extern int main();
  main();
 13a:	00000097          	auipc	ra,0x0
 13e:	ec6080e7          	jalr	-314(ra) # 0 <main>
  exit(0);
 142:	4501                	li	a0,0
 144:	00000097          	auipc	ra,0x0
 148:	274080e7          	jalr	628(ra) # 3b8 <exit>

000000000000014c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 152:	87aa                	mv	a5,a0
 154:	0585                	addi	a1,a1,1
 156:	0785                	addi	a5,a5,1
 158:	fff5c703          	lbu	a4,-1(a1)
 15c:	fee78fa3          	sb	a4,-1(a5)
 160:	fb75                	bnez	a4,154 <strcpy+0x8>
    ;
  return os;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb91                	beqz	a5,186 <strcmp+0x1e>
 174:	0005c703          	lbu	a4,0(a1)
 178:	00f71763          	bne	a4,a5,186 <strcmp+0x1e>
    p++, q++;
 17c:	0505                	addi	a0,a0,1
 17e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 180:	00054783          	lbu	a5,0(a0)
 184:	fbe5                	bnez	a5,174 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 186:	0005c503          	lbu	a0,0(a1)
}
 18a:	40a7853b          	subw	a0,a5,a0
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret

0000000000000194 <strlen>:

uint
strlen(const char *s)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 19a:	00054783          	lbu	a5,0(a0)
 19e:	cf91                	beqz	a5,1ba <strlen+0x26>
 1a0:	0505                	addi	a0,a0,1
 1a2:	87aa                	mv	a5,a0
 1a4:	86be                	mv	a3,a5
 1a6:	0785                	addi	a5,a5,1
 1a8:	fff7c703          	lbu	a4,-1(a5)
 1ac:	ff65                	bnez	a4,1a4 <strlen+0x10>
 1ae:	40a6853b          	subw	a0,a3,a0
 1b2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret
  for(n = 0; s[n]; n++)
 1ba:	4501                	li	a0,0
 1bc:	bfe5                	j	1b4 <strlen+0x20>

00000000000001be <memset>:

void*
memset(void *dst, int c, uint n)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c4:	ca19                	beqz	a2,1da <memset+0x1c>
 1c6:	87aa                	mv	a5,a0
 1c8:	1602                	slli	a2,a2,0x20
 1ca:	9201                	srli	a2,a2,0x20
 1cc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d4:	0785                	addi	a5,a5,1
 1d6:	fee79de3          	bne	a5,a4,1d0 <memset+0x12>
  }
  return dst;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret

00000000000001e0 <strchr>:

char*
strchr(const char *s, char c)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e6:	00054783          	lbu	a5,0(a0)
 1ea:	cb99                	beqz	a5,200 <strchr+0x20>
    if(*s == c)
 1ec:	00f58763          	beq	a1,a5,1fa <strchr+0x1a>
  for(; *s; s++)
 1f0:	0505                	addi	a0,a0,1
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	fbfd                	bnez	a5,1ec <strchr+0xc>
      return (char*)s;
  return 0;
 1f8:	4501                	li	a0,0
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret
  return 0;
 200:	4501                	li	a0,0
 202:	bfe5                	j	1fa <strchr+0x1a>

0000000000000204 <gets>:

char*
gets(char *buf, int max)
{
 204:	711d                	addi	sp,sp,-96
 206:	ec86                	sd	ra,88(sp)
 208:	e8a2                	sd	s0,80(sp)
 20a:	e4a6                	sd	s1,72(sp)
 20c:	e0ca                	sd	s2,64(sp)
 20e:	fc4e                	sd	s3,56(sp)
 210:	f852                	sd	s4,48(sp)
 212:	f456                	sd	s5,40(sp)
 214:	f05a                	sd	s6,32(sp)
 216:	ec5e                	sd	s7,24(sp)
 218:	1080                	addi	s0,sp,96
 21a:	8baa                	mv	s7,a0
 21c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21e:	892a                	mv	s2,a0
 220:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 222:	4aa9                	li	s5,10
 224:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 226:	89a6                	mv	s3,s1
 228:	2485                	addiw	s1,s1,1
 22a:	0344d863          	bge	s1,s4,25a <gets+0x56>
    cc = read(0, &c, 1);
 22e:	4605                	li	a2,1
 230:	faf40593          	addi	a1,s0,-81
 234:	4501                	li	a0,0
 236:	00000097          	auipc	ra,0x0
 23a:	19a080e7          	jalr	410(ra) # 3d0 <read>
    if(cc < 1)
 23e:	00a05e63          	blez	a0,25a <gets+0x56>
    buf[i++] = c;
 242:	faf44783          	lbu	a5,-81(s0)
 246:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24a:	01578763          	beq	a5,s5,258 <gets+0x54>
 24e:	0905                	addi	s2,s2,1
 250:	fd679be3          	bne	a5,s6,226 <gets+0x22>
    buf[i++] = c;
 254:	89a6                	mv	s3,s1
 256:	a011                	j	25a <gets+0x56>
 258:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 25a:	99de                	add	s3,s3,s7
 25c:	00098023          	sb	zero,0(s3)
  return buf;
}
 260:	855e                	mv	a0,s7
 262:	60e6                	ld	ra,88(sp)
 264:	6446                	ld	s0,80(sp)
 266:	64a6                	ld	s1,72(sp)
 268:	6906                	ld	s2,64(sp)
 26a:	79e2                	ld	s3,56(sp)
 26c:	7a42                	ld	s4,48(sp)
 26e:	7aa2                	ld	s5,40(sp)
 270:	7b02                	ld	s6,32(sp)
 272:	6be2                	ld	s7,24(sp)
 274:	6125                	addi	sp,sp,96
 276:	8082                	ret

0000000000000278 <stat>:

int
stat(const char *n, struct stat *st)
{
 278:	1101                	addi	sp,sp,-32
 27a:	ec06                	sd	ra,24(sp)
 27c:	e822                	sd	s0,16(sp)
 27e:	e04a                	sd	s2,0(sp)
 280:	1000                	addi	s0,sp,32
 282:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 284:	4581                	li	a1,0
 286:	00000097          	auipc	ra,0x0
 28a:	172080e7          	jalr	370(ra) # 3f8 <open>
  if(fd < 0)
 28e:	02054663          	bltz	a0,2ba <stat+0x42>
 292:	e426                	sd	s1,8(sp)
 294:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 296:	85ca                	mv	a1,s2
 298:	00000097          	auipc	ra,0x0
 29c:	178080e7          	jalr	376(ra) # 410 <fstat>
 2a0:	892a                	mv	s2,a0
  close(fd);
 2a2:	8526                	mv	a0,s1
 2a4:	00000097          	auipc	ra,0x0
 2a8:	13c080e7          	jalr	316(ra) # 3e0 <close>
  return r;
 2ac:	64a2                	ld	s1,8(sp)
}
 2ae:	854a                	mv	a0,s2
 2b0:	60e2                	ld	ra,24(sp)
 2b2:	6442                	ld	s0,16(sp)
 2b4:	6902                	ld	s2,0(sp)
 2b6:	6105                	addi	sp,sp,32
 2b8:	8082                	ret
    return -1;
 2ba:	597d                	li	s2,-1
 2bc:	bfcd                	j	2ae <stat+0x36>

00000000000002be <atoi>:

int
atoi(const char *s)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c4:	00054683          	lbu	a3,0(a0)
 2c8:	fd06879b          	addiw	a5,a3,-48
 2cc:	0ff7f793          	zext.b	a5,a5
 2d0:	4625                	li	a2,9
 2d2:	02f66863          	bltu	a2,a5,302 <atoi+0x44>
 2d6:	872a                	mv	a4,a0
  n = 0;
 2d8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2da:	0705                	addi	a4,a4,1
 2dc:	0025179b          	slliw	a5,a0,0x2
 2e0:	9fa9                	addw	a5,a5,a0
 2e2:	0017979b          	slliw	a5,a5,0x1
 2e6:	9fb5                	addw	a5,a5,a3
 2e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ec:	00074683          	lbu	a3,0(a4)
 2f0:	fd06879b          	addiw	a5,a3,-48
 2f4:	0ff7f793          	zext.b	a5,a5
 2f8:	fef671e3          	bgeu	a2,a5,2da <atoi+0x1c>
  return n;
}
 2fc:	6422                	ld	s0,8(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
  n = 0;
 302:	4501                	li	a0,0
 304:	bfe5                	j	2fc <atoi+0x3e>

0000000000000306 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30c:	02b57463          	bgeu	a0,a1,334 <memmove+0x2e>
    while(n-- > 0)
 310:	00c05f63          	blez	a2,32e <memmove+0x28>
 314:	1602                	slli	a2,a2,0x20
 316:	9201                	srli	a2,a2,0x20
 318:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31c:	872a                	mv	a4,a0
      *dst++ = *src++;
 31e:	0585                	addi	a1,a1,1
 320:	0705                	addi	a4,a4,1
 322:	fff5c683          	lbu	a3,-1(a1)
 326:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32a:	fef71ae3          	bne	a4,a5,31e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
    dst += n;
 334:	00c50733          	add	a4,a0,a2
    src += n;
 338:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 33a:	fec05ae3          	blez	a2,32e <memmove+0x28>
 33e:	fff6079b          	addiw	a5,a2,-1
 342:	1782                	slli	a5,a5,0x20
 344:	9381                	srli	a5,a5,0x20
 346:	fff7c793          	not	a5,a5
 34a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 34c:	15fd                	addi	a1,a1,-1
 34e:	177d                	addi	a4,a4,-1
 350:	0005c683          	lbu	a3,0(a1)
 354:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 358:	fee79ae3          	bne	a5,a4,34c <memmove+0x46>
 35c:	bfc9                	j	32e <memmove+0x28>

000000000000035e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 364:	ca05                	beqz	a2,394 <memcmp+0x36>
 366:	fff6069b          	addiw	a3,a2,-1
 36a:	1682                	slli	a3,a3,0x20
 36c:	9281                	srli	a3,a3,0x20
 36e:	0685                	addi	a3,a3,1
 370:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 372:	00054783          	lbu	a5,0(a0)
 376:	0005c703          	lbu	a4,0(a1)
 37a:	00e79863          	bne	a5,a4,38a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 37e:	0505                	addi	a0,a0,1
    p2++;
 380:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 382:	fed518e3          	bne	a0,a3,372 <memcmp+0x14>
  }
  return 0;
 386:	4501                	li	a0,0
 388:	a019                	j	38e <memcmp+0x30>
      return *p1 - *p2;
 38a:	40e7853b          	subw	a0,a5,a4
}
 38e:	6422                	ld	s0,8(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret
  return 0;
 394:	4501                	li	a0,0
 396:	bfe5                	j	38e <memcmp+0x30>

0000000000000398 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e406                	sd	ra,8(sp)
 39c:	e022                	sd	s0,0(sp)
 39e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a0:	00000097          	auipc	ra,0x0
 3a4:	f66080e7          	jalr	-154(ra) # 306 <memmove>
}
 3a8:	60a2                	ld	ra,8(sp)
 3aa:	6402                	ld	s0,0(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret

00000000000003b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b0:	4885                	li	a7,1
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3b8:	4889                	li	a7,2
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c0:	488d                	li	a7,3
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3c8:	4891                	li	a7,4
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <read>:
.global read
read:
 li a7, SYS_read
 3d0:	4895                	li	a7,5
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <write>:
.global write
write:
 li a7, SYS_write
 3d8:	48c1                	li	a7,16
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <close>:
.global close
close:
 li a7, SYS_close
 3e0:	48d5                	li	a7,21
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3e8:	4899                	li	a7,6
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f0:	489d                	li	a7,7
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <open>:
.global open
open:
 li a7, SYS_open
 3f8:	48bd                	li	a7,15
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 400:	48c5                	li	a7,17
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 408:	48c9                	li	a7,18
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 410:	48a1                	li	a7,8
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <link>:
.global link
link:
 li a7, SYS_link
 418:	48cd                	li	a7,19
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 420:	48d1                	li	a7,20
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 428:	48a5                	li	a7,9
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <dup>:
.global dup
dup:
 li a7, SYS_dup
 430:	48a9                	li	a7,10
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 438:	48ad                	li	a7,11
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 440:	48b1                	li	a7,12
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 448:	48b5                	li	a7,13
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 450:	48b9                	li	a7,14
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 458:	48d9                	li	a7,22
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <sem_close>:
.global sem_close
sem_close:
 li a7, SYS_sem_close
 460:	48dd                	li	a7,23
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <sem_down>:
.global sem_down
sem_down:
 li a7, SYS_sem_down
 468:	48e5                	li	a7,25
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <sem_up>:
.global sem_up
sem_up:
 li a7, SYS_sem_up
 470:	48e1                	li	a7,24
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 478:	1101                	addi	sp,sp,-32
 47a:	ec06                	sd	ra,24(sp)
 47c:	e822                	sd	s0,16(sp)
 47e:	1000                	addi	s0,sp,32
 480:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 484:	4605                	li	a2,1
 486:	fef40593          	addi	a1,s0,-17
 48a:	00000097          	auipc	ra,0x0
 48e:	f4e080e7          	jalr	-178(ra) # 3d8 <write>
}
 492:	60e2                	ld	ra,24(sp)
 494:	6442                	ld	s0,16(sp)
 496:	6105                	addi	sp,sp,32
 498:	8082                	ret

000000000000049a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 49a:	7139                	addi	sp,sp,-64
 49c:	fc06                	sd	ra,56(sp)
 49e:	f822                	sd	s0,48(sp)
 4a0:	f426                	sd	s1,40(sp)
 4a2:	0080                	addi	s0,sp,64
 4a4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4a6:	c299                	beqz	a3,4ac <printint+0x12>
 4a8:	0805cb63          	bltz	a1,53e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ac:	2581                	sext.w	a1,a1
  neg = 0;
 4ae:	4881                	li	a7,0
 4b0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4b4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4b6:	2601                	sext.w	a2,a2
 4b8:	00000517          	auipc	a0,0x0
 4bc:	53050513          	addi	a0,a0,1328 # 9e8 <digits>
 4c0:	883a                	mv	a6,a4
 4c2:	2705                	addiw	a4,a4,1
 4c4:	02c5f7bb          	remuw	a5,a1,a2
 4c8:	1782                	slli	a5,a5,0x20
 4ca:	9381                	srli	a5,a5,0x20
 4cc:	97aa                	add	a5,a5,a0
 4ce:	0007c783          	lbu	a5,0(a5)
 4d2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4d6:	0005879b          	sext.w	a5,a1
 4da:	02c5d5bb          	divuw	a1,a1,a2
 4de:	0685                	addi	a3,a3,1
 4e0:	fec7f0e3          	bgeu	a5,a2,4c0 <printint+0x26>
  if(neg)
 4e4:	00088c63          	beqz	a7,4fc <printint+0x62>
    buf[i++] = '-';
 4e8:	fd070793          	addi	a5,a4,-48
 4ec:	00878733          	add	a4,a5,s0
 4f0:	02d00793          	li	a5,45
 4f4:	fef70823          	sb	a5,-16(a4)
 4f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4fc:	02e05c63          	blez	a4,534 <printint+0x9a>
 500:	f04a                	sd	s2,32(sp)
 502:	ec4e                	sd	s3,24(sp)
 504:	fc040793          	addi	a5,s0,-64
 508:	00e78933          	add	s2,a5,a4
 50c:	fff78993          	addi	s3,a5,-1
 510:	99ba                	add	s3,s3,a4
 512:	377d                	addiw	a4,a4,-1
 514:	1702                	slli	a4,a4,0x20
 516:	9301                	srli	a4,a4,0x20
 518:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 51c:	fff94583          	lbu	a1,-1(s2)
 520:	8526                	mv	a0,s1
 522:	00000097          	auipc	ra,0x0
 526:	f56080e7          	jalr	-170(ra) # 478 <putc>
  while(--i >= 0)
 52a:	197d                	addi	s2,s2,-1
 52c:	ff3918e3          	bne	s2,s3,51c <printint+0x82>
 530:	7902                	ld	s2,32(sp)
 532:	69e2                	ld	s3,24(sp)
}
 534:	70e2                	ld	ra,56(sp)
 536:	7442                	ld	s0,48(sp)
 538:	74a2                	ld	s1,40(sp)
 53a:	6121                	addi	sp,sp,64
 53c:	8082                	ret
    x = -xx;
 53e:	40b005bb          	negw	a1,a1
    neg = 1;
 542:	4885                	li	a7,1
    x = -xx;
 544:	b7b5                	j	4b0 <printint+0x16>

0000000000000546 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 546:	715d                	addi	sp,sp,-80
 548:	e486                	sd	ra,72(sp)
 54a:	e0a2                	sd	s0,64(sp)
 54c:	f84a                	sd	s2,48(sp)
 54e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 550:	0005c903          	lbu	s2,0(a1)
 554:	1a090a63          	beqz	s2,708 <vprintf+0x1c2>
 558:	fc26                	sd	s1,56(sp)
 55a:	f44e                	sd	s3,40(sp)
 55c:	f052                	sd	s4,32(sp)
 55e:	ec56                	sd	s5,24(sp)
 560:	e85a                	sd	s6,16(sp)
 562:	e45e                	sd	s7,8(sp)
 564:	8aaa                	mv	s5,a0
 566:	8bb2                	mv	s7,a2
 568:	00158493          	addi	s1,a1,1
  state = 0;
 56c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 56e:	02500a13          	li	s4,37
 572:	4b55                	li	s6,21
 574:	a839                	j	592 <vprintf+0x4c>
        putc(fd, c);
 576:	85ca                	mv	a1,s2
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	efe080e7          	jalr	-258(ra) # 478 <putc>
 582:	a019                	j	588 <vprintf+0x42>
    } else if(state == '%'){
 584:	01498d63          	beq	s3,s4,59e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 588:	0485                	addi	s1,s1,1
 58a:	fff4c903          	lbu	s2,-1(s1)
 58e:	16090763          	beqz	s2,6fc <vprintf+0x1b6>
    if(state == 0){
 592:	fe0999e3          	bnez	s3,584 <vprintf+0x3e>
      if(c == '%'){
 596:	ff4910e3          	bne	s2,s4,576 <vprintf+0x30>
        state = '%';
 59a:	89d2                	mv	s3,s4
 59c:	b7f5                	j	588 <vprintf+0x42>
      if(c == 'd'){
 59e:	13490463          	beq	s2,s4,6c6 <vprintf+0x180>
 5a2:	f9d9079b          	addiw	a5,s2,-99
 5a6:	0ff7f793          	zext.b	a5,a5
 5aa:	12fb6763          	bltu	s6,a5,6d8 <vprintf+0x192>
 5ae:	f9d9079b          	addiw	a5,s2,-99
 5b2:	0ff7f713          	zext.b	a4,a5
 5b6:	12eb6163          	bltu	s6,a4,6d8 <vprintf+0x192>
 5ba:	00271793          	slli	a5,a4,0x2
 5be:	00000717          	auipc	a4,0x0
 5c2:	3d270713          	addi	a4,a4,978 # 990 <malloc+0x198>
 5c6:	97ba                	add	a5,a5,a4
 5c8:	439c                	lw	a5,0(a5)
 5ca:	97ba                	add	a5,a5,a4
 5cc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4685                	li	a3,1
 5d4:	4629                	li	a2,10
 5d6:	000ba583          	lw	a1,0(s7)
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	ebe080e7          	jalr	-322(ra) # 49a <printint>
 5e4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b745                	j	588 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	4681                	li	a3,0
 5f0:	4629                	li	a2,10
 5f2:	000ba583          	lw	a1,0(s7)
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	ea2080e7          	jalr	-350(ra) # 49a <printint>
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
 604:	b751                	j	588 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 606:	008b8913          	addi	s2,s7,8
 60a:	4681                	li	a3,0
 60c:	4641                	li	a2,16
 60e:	000ba583          	lw	a1,0(s7)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	e86080e7          	jalr	-378(ra) # 49a <printint>
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	b7a5                	j	588 <vprintf+0x42>
 622:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 624:	008b8c13          	addi	s8,s7,8
 628:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 62c:	03000593          	li	a1,48
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e46080e7          	jalr	-442(ra) # 478 <putc>
  putc(fd, 'x');
 63a:	07800593          	li	a1,120
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	e38080e7          	jalr	-456(ra) # 478 <putc>
 648:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64a:	00000b97          	auipc	s7,0x0
 64e:	39eb8b93          	addi	s7,s7,926 # 9e8 <digits>
 652:	03c9d793          	srli	a5,s3,0x3c
 656:	97de                	add	a5,a5,s7
 658:	0007c583          	lbu	a1,0(a5)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e1a080e7          	jalr	-486(ra) # 478 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 666:	0992                	slli	s3,s3,0x4
 668:	397d                	addiw	s2,s2,-1
 66a:	fe0914e3          	bnez	s2,652 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 66e:	8be2                	mv	s7,s8
      state = 0;
 670:	4981                	li	s3,0
 672:	6c02                	ld	s8,0(sp)
 674:	bf11                	j	588 <vprintf+0x42>
        s = va_arg(ap, char*);
 676:	008b8993          	addi	s3,s7,8
 67a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 67e:	02090163          	beqz	s2,6a0 <vprintf+0x15a>
        while(*s != 0){
 682:	00094583          	lbu	a1,0(s2)
 686:	c9a5                	beqz	a1,6f6 <vprintf+0x1b0>
          putc(fd, *s);
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	dee080e7          	jalr	-530(ra) # 478 <putc>
          s++;
 692:	0905                	addi	s2,s2,1
        while(*s != 0){
 694:	00094583          	lbu	a1,0(s2)
 698:	f9e5                	bnez	a1,688 <vprintf+0x142>
        s = va_arg(ap, char*);
 69a:	8bce                	mv	s7,s3
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b5ed                	j	588 <vprintf+0x42>
          s = "(null)";
 6a0:	00000917          	auipc	s2,0x0
 6a4:	2e890913          	addi	s2,s2,744 # 988 <malloc+0x190>
        while(*s != 0){
 6a8:	02800593          	li	a1,40
 6ac:	bff1                	j	688 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	000bc583          	lbu	a1,0(s7)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	dc0080e7          	jalr	-576(ra) # 478 <putc>
 6c0:	8bca                	mv	s7,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	b5d1                	j	588 <vprintf+0x42>
        putc(fd, c);
 6c6:	02500593          	li	a1,37
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	dac080e7          	jalr	-596(ra) # 478 <putc>
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	bd4d                	j	588 <vprintf+0x42>
        putc(fd, '%');
 6d8:	02500593          	li	a1,37
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	d9a080e7          	jalr	-614(ra) # 478 <putc>
        putc(fd, c);
 6e6:	85ca                	mv	a1,s2
 6e8:	8556                	mv	a0,s5
 6ea:	00000097          	auipc	ra,0x0
 6ee:	d8e080e7          	jalr	-626(ra) # 478 <putc>
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	bd51                	j	588 <vprintf+0x42>
        s = va_arg(ap, char*);
 6f6:	8bce                	mv	s7,s3
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b579                	j	588 <vprintf+0x42>
 6fc:	74e2                	ld	s1,56(sp)
 6fe:	79a2                	ld	s3,40(sp)
 700:	7a02                	ld	s4,32(sp)
 702:	6ae2                	ld	s5,24(sp)
 704:	6b42                	ld	s6,16(sp)
 706:	6ba2                	ld	s7,8(sp)
    }
  }
}
 708:	60a6                	ld	ra,72(sp)
 70a:	6406                	ld	s0,64(sp)
 70c:	7942                	ld	s2,48(sp)
 70e:	6161                	addi	sp,sp,80
 710:	8082                	ret

0000000000000712 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 712:	715d                	addi	sp,sp,-80
 714:	ec06                	sd	ra,24(sp)
 716:	e822                	sd	s0,16(sp)
 718:	1000                	addi	s0,sp,32
 71a:	e010                	sd	a2,0(s0)
 71c:	e414                	sd	a3,8(s0)
 71e:	e818                	sd	a4,16(s0)
 720:	ec1c                	sd	a5,24(s0)
 722:	03043023          	sd	a6,32(s0)
 726:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72e:	8622                	mv	a2,s0
 730:	00000097          	auipc	ra,0x0
 734:	e16080e7          	jalr	-490(ra) # 546 <vprintf>
}
 738:	60e2                	ld	ra,24(sp)
 73a:	6442                	ld	s0,16(sp)
 73c:	6161                	addi	sp,sp,80
 73e:	8082                	ret

0000000000000740 <printf>:

void
printf(const char *fmt, ...)
{
 740:	711d                	addi	sp,sp,-96
 742:	ec06                	sd	ra,24(sp)
 744:	e822                	sd	s0,16(sp)
 746:	1000                	addi	s0,sp,32
 748:	e40c                	sd	a1,8(s0)
 74a:	e810                	sd	a2,16(s0)
 74c:	ec14                	sd	a3,24(s0)
 74e:	f018                	sd	a4,32(s0)
 750:	f41c                	sd	a5,40(s0)
 752:	03043823          	sd	a6,48(s0)
 756:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 75a:	00840613          	addi	a2,s0,8
 75e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 762:	85aa                	mv	a1,a0
 764:	4505                	li	a0,1
 766:	00000097          	auipc	ra,0x0
 76a:	de0080e7          	jalr	-544(ra) # 546 <vprintf>
}
 76e:	60e2                	ld	ra,24(sp)
 770:	6442                	ld	s0,16(sp)
 772:	6125                	addi	sp,sp,96
 774:	8082                	ret

0000000000000776 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 776:	1141                	addi	sp,sp,-16
 778:	e422                	sd	s0,8(sp)
 77a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 780:	00001797          	auipc	a5,0x1
 784:	c807b783          	ld	a5,-896(a5) # 1400 <freep>
 788:	a02d                	j	7b2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 78a:	4618                	lw	a4,8(a2)
 78c:	9f2d                	addw	a4,a4,a1
 78e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 792:	6398                	ld	a4,0(a5)
 794:	6310                	ld	a2,0(a4)
 796:	a83d                	j	7d4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 798:	ff852703          	lw	a4,-8(a0)
 79c:	9f31                	addw	a4,a4,a2
 79e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7a0:	ff053683          	ld	a3,-16(a0)
 7a4:	a091                	j	7e8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a6:	6398                	ld	a4,0(a5)
 7a8:	00e7e463          	bltu	a5,a4,7b0 <free+0x3a>
 7ac:	00e6ea63          	bltu	a3,a4,7c0 <free+0x4a>
{
 7b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b2:	fed7fae3          	bgeu	a5,a3,7a6 <free+0x30>
 7b6:	6398                	ld	a4,0(a5)
 7b8:	00e6e463          	bltu	a3,a4,7c0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7bc:	fee7eae3          	bltu	a5,a4,7b0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7c0:	ff852583          	lw	a1,-8(a0)
 7c4:	6390                	ld	a2,0(a5)
 7c6:	02059813          	slli	a6,a1,0x20
 7ca:	01c85713          	srli	a4,a6,0x1c
 7ce:	9736                	add	a4,a4,a3
 7d0:	fae60de3          	beq	a2,a4,78a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7d4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d8:	4790                	lw	a2,8(a5)
 7da:	02061593          	slli	a1,a2,0x20
 7de:	01c5d713          	srli	a4,a1,0x1c
 7e2:	973e                	add	a4,a4,a5
 7e4:	fae68ae3          	beq	a3,a4,798 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7e8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ea:	00001717          	auipc	a4,0x1
 7ee:	c0f73b23          	sd	a5,-1002(a4) # 1400 <freep>
}
 7f2:	6422                	ld	s0,8(sp)
 7f4:	0141                	addi	sp,sp,16
 7f6:	8082                	ret

00000000000007f8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f8:	7139                	addi	sp,sp,-64
 7fa:	fc06                	sd	ra,56(sp)
 7fc:	f822                	sd	s0,48(sp)
 7fe:	f426                	sd	s1,40(sp)
 800:	ec4e                	sd	s3,24(sp)
 802:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 804:	02051493          	slli	s1,a0,0x20
 808:	9081                	srli	s1,s1,0x20
 80a:	04bd                	addi	s1,s1,15
 80c:	8091                	srli	s1,s1,0x4
 80e:	0014899b          	addiw	s3,s1,1
 812:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 814:	00001517          	auipc	a0,0x1
 818:	bec53503          	ld	a0,-1044(a0) # 1400 <freep>
 81c:	c915                	beqz	a0,850 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 820:	4798                	lw	a4,8(a5)
 822:	08977e63          	bgeu	a4,s1,8be <malloc+0xc6>
 826:	f04a                	sd	s2,32(sp)
 828:	e852                	sd	s4,16(sp)
 82a:	e456                	sd	s5,8(sp)
 82c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 82e:	8a4e                	mv	s4,s3
 830:	0009871b          	sext.w	a4,s3
 834:	6685                	lui	a3,0x1
 836:	00d77363          	bgeu	a4,a3,83c <malloc+0x44>
 83a:	6a05                	lui	s4,0x1
 83c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 840:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 844:	00001917          	auipc	s2,0x1
 848:	bbc90913          	addi	s2,s2,-1092 # 1400 <freep>
  if(p == (char*)-1)
 84c:	5afd                	li	s5,-1
 84e:	a091                	j	892 <malloc+0x9a>
 850:	f04a                	sd	s2,32(sp)
 852:	e852                	sd	s4,16(sp)
 854:	e456                	sd	s5,8(sp)
 856:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 858:	00001797          	auipc	a5,0x1
 85c:	bb878793          	addi	a5,a5,-1096 # 1410 <base>
 860:	00001717          	auipc	a4,0x1
 864:	baf73023          	sd	a5,-1120(a4) # 1400 <freep>
 868:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86e:	b7c1                	j	82e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 870:	6398                	ld	a4,0(a5)
 872:	e118                	sd	a4,0(a0)
 874:	a08d                	j	8d6 <malloc+0xde>
  hp->s.size = nu;
 876:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 87a:	0541                	addi	a0,a0,16
 87c:	00000097          	auipc	ra,0x0
 880:	efa080e7          	jalr	-262(ra) # 776 <free>
  return freep;
 884:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 888:	c13d                	beqz	a0,8ee <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88c:	4798                	lw	a4,8(a5)
 88e:	02977463          	bgeu	a4,s1,8b6 <malloc+0xbe>
    if(p == freep)
 892:	00093703          	ld	a4,0(s2)
 896:	853e                	mv	a0,a5
 898:	fef719e3          	bne	a4,a5,88a <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 89c:	8552                	mv	a0,s4
 89e:	00000097          	auipc	ra,0x0
 8a2:	ba2080e7          	jalr	-1118(ra) # 440 <sbrk>
  if(p == (char*)-1)
 8a6:	fd5518e3          	bne	a0,s5,876 <malloc+0x7e>
        return 0;
 8aa:	4501                	li	a0,0
 8ac:	7902                	ld	s2,32(sp)
 8ae:	6a42                	ld	s4,16(sp)
 8b0:	6aa2                	ld	s5,8(sp)
 8b2:	6b02                	ld	s6,0(sp)
 8b4:	a03d                	j	8e2 <malloc+0xea>
 8b6:	7902                	ld	s2,32(sp)
 8b8:	6a42                	ld	s4,16(sp)
 8ba:	6aa2                	ld	s5,8(sp)
 8bc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8be:	fae489e3          	beq	s1,a4,870 <malloc+0x78>
        p->s.size -= nunits;
 8c2:	4137073b          	subw	a4,a4,s3
 8c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c8:	02071693          	slli	a3,a4,0x20
 8cc:	01c6d713          	srli	a4,a3,0x1c
 8d0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d6:	00001717          	auipc	a4,0x1
 8da:	b2a73523          	sd	a0,-1238(a4) # 1400 <freep>
      return (void*)(p + 1);
 8de:	01078513          	addi	a0,a5,16
  }
}
 8e2:	70e2                	ld	ra,56(sp)
 8e4:	7442                	ld	s0,48(sp)
 8e6:	74a2                	ld	s1,40(sp)
 8e8:	69e2                	ld	s3,24(sp)
 8ea:	6121                	addi	sp,sp,64
 8ec:	8082                	ret
 8ee:	7902                	ld	s2,32(sp)
 8f0:	6a42                	ld	s4,16(sp)
 8f2:	6aa2                	ld	s5,8(sp)
 8f4:	6b02                	ld	s6,0(sp)
 8f6:	b7f5                	j	8e2 <malloc+0xea>
