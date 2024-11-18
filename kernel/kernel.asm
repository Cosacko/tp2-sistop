
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	3a013103          	ld	sp,928(sp) # 8000b3a0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	addi	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	0000b717          	auipc	a4,0xb
    80000054:	3b070713          	addi	a4,a4,944 # 8000b400 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	d7e78793          	addi	a5,a5,-642 # 80005de0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd7f8f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2678793          	addi	a5,a5,-474 # 80000ed2 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	430080e7          	jalr	1072(ra) # 8000255a <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7e4080e7          	jalr	2020(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	addi	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00013517          	auipc	a0,0x13
    80000190:	3b450513          	addi	a0,a0,948 # 80013540 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	3a448493          	addi	s1,s1,932 # 80013540 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	43490913          	addi	s2,s2,1076 # 800135d8 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	896080e7          	jalr	-1898(ra) # 80001a52 <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	1e0080e7          	jalr	480(ra) # 800023a4 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	f2a080e7          	jalr	-214(ra) # 800020fc <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	35870713          	addi	a4,a4,856 # 80013540 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	2ea080e7          	jalr	746(ra) # 80002504 <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
      break;

    dst++;
    80000228:	0a05                	addi	s4,s4,1
    --n;
    8000022a:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000236:	00013517          	auipc	a0,0x13
    8000023a:	30a50513          	addi	a0,a0,778 # 80013540 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	aae080e7          	jalr	-1362(ra) # 80000cec <release>
        return -1;
    80000246:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	addi	sp,sp,96
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
        cons.r--;
    80000264:	00013717          	auipc	a4,0x13
    80000268:	36f72a23          	sw	a5,884(a4) # 800135d8 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	2c650513          	addi	a0,a0,710 # 80013540 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
  return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
    uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	59c080e7          	jalr	1436(ra) # 80000840 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	58a080e7          	jalr	1418(ra) # 80000840 <uartputc_sync>
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	574080e7          	jalr	1396(ra) # 80000840 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d6:	1101                	addi	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	addi	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00013517          	auipc	a0,0x13
    800002e6:	25e50513          	addi	a0,a0,606 # 80013540 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	94e080e7          	jalr	-1714(ra) # 80000c38 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	2a8080e7          	jalr	680(ra) # 800025b0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	23050513          	addi	a0,a0,560 # 80013540 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9d4080e7          	jalr	-1580(ra) # 80000cec <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	addi	sp,sp,32
    80000328:	8082                	ret
  switch(c){
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000332:	00013717          	auipc	a4,0x13
    80000336:	20e70713          	addi	a4,a4,526 # 80013540 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
      consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00013797          	auipc	a5,0x13
    80000360:	1e478793          	addi	a5,a5,484 # 80013540 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addiw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	andi	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00013797          	auipc	a5,0x13
    8000038e:	24e7a783          	lw	a5,590(a5) # 800135d8 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	1a070713          	addi	a4,a4,416 # 80013540 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	19048493          	addi	s1,s1,400 # 80013540 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	07f7f713          	andi	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
      cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
    while(cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f6:	00013717          	auipc	a4,0x13
    800003fa:	14a70713          	addi	a4,a4,330 # 80013540 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	1cf72a23          	sw	a5,468(a4) # 800135e0 <cons+0xa0>
      consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
      consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00013797          	auipc	a5,0x13
    80000436:	10e78793          	addi	a5,a5,270 # 80013540 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addiw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	andi	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000456:	00013797          	auipc	a5,0x13
    8000045a:	18c7a323          	sw	a2,390(a5) # 800135dc <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	17a50513          	addi	a0,a0,378 # 800135d8 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	cfa080e7          	jalr	-774(ra) # 80002160 <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void
consoleinit(void)
{
    80000470:	1141                	addi	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b8858593          	addi	a1,a1,-1144 # 80008000 <etext>
    80000480:	00013517          	auipc	a0,0x13
    80000484:	0c050513          	addi	a0,a0,192 # 80013540 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00023797          	auipc	a5,0x23
    8000049c:	24078793          	addi	a5,a5,576 # 800236d8 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	addi	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	addi	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	addi	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	addi	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	2c260613          	addi	a2,a2,706 # 80008798 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

  if(sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
    buf[i++] = '-';
    80000506:	fe070793          	addi	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	addi	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	addi	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addiw	a4,a4,-1
    80000532:	1702                	slli	a4,a4,0x20
    80000534:	9301                	srli	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
  while(--i >= 0)
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
    x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	addi	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00013797          	auipc	a5,0x13
    80000570:	0807aa23          	sw	zero,148(a5) # 80013600 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	addi	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	addi	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	0000b717          	auipc	a4,0xb
    800005a4:	e2f72023          	sw	a5,-480(a4) # 8000b3c0 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	addi	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00013d17          	auipc	s10,0x13
    800005ce:	036d2d03          	lw	s10,54(s10) # 80013600 <pr+0x18>
  if(locking)
    800005d2:	040d1463          	bnez	s10,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050b63          	beqz	a0,8000077c <printf+0x1d2>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	ec6e                	sd	s11,24(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000608:	00008a97          	auipc	s5,0x8
    8000060c:	190a8a93          	addi	s5,s5,400 # 80008798 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00013517          	auipc	a0,0x13
    8000061e:	fce50513          	addi	a0,a0,-50 # 800135e8 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	616080e7          	jalr	1558(ra) # 80000c38 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	addi	a0,a0,-1566 # 80008020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c46080e7          	jalr	-954(ra) # 80000294 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2985                	addiw	s3,s3,1
    80000658:	013a07b3          	add	a5,s4,s3
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c0>
    if(c != '%'){
    80000664:	ff6515e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	2985                	addiw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000676:	10078b63          	beqz	a5,8000078c <printf+0x1e2>
    switch(c){
    8000067a:	05778a63          	beq	a5,s7,800006ce <printf+0x124>
    8000067e:	02fbf663          	bgeu	s7,a5,800006aa <printf+0x100>
    80000682:	09878863          	beq	a5,s8,80000712 <printf+0x168>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79563          	bne	a5,a4,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85e6                	mv	a1,s9
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e1c080e7          	jalr	-484(ra) # 800004bc <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	09678f63          	beq	a5,s6,80000748 <printf+0x19e>
    800006ae:	0bb79363          	bne	a5,s11,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	df8080e7          	jalr	-520(ra) # 800004bc <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	bb2080e7          	jalr	-1102(ra) # 80000294 <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	ba6080e7          	jalr	-1114(ra) # 80000294 <consputc>
    800006f6:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srli	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b92080e7          	jalr	-1134(ra) # 80000294 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	slli	s2,s2,0x4
    8000070c:	34fd                	addiw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x14e>
    80000710:	b799                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	addi	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x190>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d905                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b6c080e7          	jalr	-1172(ra) # 80000294 <consputc>
      for(; *s; s++)
    80000730:	0485                	addi	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x17e>
    80000738:	bf39                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	addi	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x17e>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b4a080e7          	jalr	-1206(ra) # 80000294 <consputc>
      break;
    80000752:	b711                	j	80000656 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b3e080e7          	jalr	-1218(ra) # 80000294 <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b34080e7          	jalr	-1228(ra) # 80000294 <consputc>
      break;
    80000768:	b5fd                	j	80000656 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077c:	020d1263          	bnez	s10,800007a0 <printf+0x1f6>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	7d02                	ld	s10,32(sp)
    80000788:	6129                	addi	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	6de2                	ld	s11,24(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d2>
    release(&pr.lock);
    800007a0:	00013517          	auipc	a0,0x13
    800007a4:	e4850513          	addi	a0,a0,-440 # 800135e8 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	544080e7          	jalr	1348(ra) # 80000cec <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d6>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1101                	addi	sp,sp,-32
    800007b4:	ec06                	sd	ra,24(sp)
    800007b6:	e822                	sd	s0,16(sp)
    800007b8:	e426                	sd	s1,8(sp)
    800007ba:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007bc:	00013497          	auipc	s1,0x13
    800007c0:	e2c48493          	addi	s1,s1,-468 # 800135e8 <pr>
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	86c58593          	addi	a1,a1,-1940 # 80008030 <etext+0x30>
    800007cc:	8526                	mv	a0,s1
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	3da080e7          	jalr	986(ra) # 80000ba8 <initlock>
  pr.locking = 1;
    800007d6:	4785                	li	a5,1
    800007d8:	cc9c                	sw	a5,24(s1)
}
    800007da:	60e2                	ld	ra,24(sp)
    800007dc:	6442                	ld	s0,16(sp)
    800007de:	64a2                	ld	s1,8(sp)
    800007e0:	6105                	addi	sp,sp,32
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	addi	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	10000737          	lui	a4,0x10000
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	addi	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00013517          	auipc	a0,0x13
    8000082c:	de050513          	addi	a0,a0,-544 # 80013608 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	378080e7          	jalr	888(ra) # 80000ba8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	addi	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	addi	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a0080e7          	jalr	928(ra) # 80000bec <push_off>

  if(panicked){
    80000854:	0000b797          	auipc	a5,0xb
    80000858:	b6c7a783          	lw	a5,-1172(a5) # 8000b3c0 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	andi	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	412080e7          	jalr	1042(ra) # 80000c8c <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	addi	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	0000b797          	auipc	a5,0xb
    80000892:	b3a7b783          	ld	a5,-1222(a5) # 8000b3c8 <uart_tx_r>
    80000896:	0000b717          	auipc	a4,0xb
    8000089a:	b3a73703          	ld	a4,-1222(a4) # 8000b3d0 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	addi	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00013a97          	auipc	s5,0x13
    800008c0:	d4ca8a93          	addi	s5,s5,-692 # 80013608 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	0000b497          	auipc	s1,0xb
    800008c8:	b0448493          	addi	s1,s1,-1276 # 8000b3c8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	0000b997          	auipc	s3,0xb
    800008d4:	b0098993          	addi	s3,s3,-1280 # 8000b3d0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	andi	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	andi	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	addi	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	86e080e7          	jalr	-1938(ra) # 80002160 <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	addi	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	addi	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	addi	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00013517          	auipc	a0,0x13
    80000934:	cd850513          	addi	a0,a0,-808 # 80013608 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	0000b797          	auipc	a5,0xb
    80000944:	a807a783          	lw	a5,-1408(a5) # 8000b3c0 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	0000b717          	auipc	a4,0xb
    8000094e:	a8673703          	ld	a4,-1402(a4) # 8000b3d0 <uart_tx_w>
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	a767b783          	ld	a5,-1418(a5) # 8000b3c8 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00013997          	auipc	s3,0x13
    80000962:	caa98993          	addi	s3,s3,-854 # 80013608 <uart_tx_lock>
    80000966:	0000b497          	auipc	s1,0xb
    8000096a:	a6248493          	addi	s1,s1,-1438 # 8000b3c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	0000b917          	auipc	s2,0xb
    80000972:	a6290913          	addi	s2,s2,-1438 # 8000b3d0 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00001097          	auipc	ra,0x1
    80000982:	77e080e7          	jalr	1918(ra) # 800020fc <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00013497          	auipc	s1,0x13
    80000998:	c7448493          	addi	s1,s1,-908 # 80013608 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	0000b797          	auipc	a5,0xb
    800009ac:	a2e7b423          	sd	a4,-1496(a5) # 8000b3d0 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	332080e7          	jalr	818(ra) # 80000cec <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	addi	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	addi	sp,sp,-16
    800009d6:	e422                	sd	s0,8(sp)
    800009d8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009e0:	0007c783          	lbu	a5,0(a5)
    800009e4:	8b85                	andi	a5,a5,1
    800009e6:	cb81                	beqz	a5,800009f6 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	addi	sp,sp,16
    800009f4:	8082                	ret
    return -1;
    800009f6:	557d                	li	a0,-1
    800009f8:	bfe5                	j	800009f0 <uartgetc+0x1c>

00000000800009fa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a04:	54fd                	li	s1,-1
    80000a06:	a029                	j	80000a10 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	8ce080e7          	jalr	-1842(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	fc4080e7          	jalr	-60(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a18:	fe9518e3          	bne	a0,s1,80000a08 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1c:	00013497          	auipc	s1,0x13
    80000a20:	bec48493          	addi	s1,s1,-1044 # 80013608 <uart_tx_lock>
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	212080e7          	jalr	530(ra) # 80000c38 <acquire>
  uartstart();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	e60080e7          	jalr	-416(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2b4080e7          	jalr	692(ra) # 80000cec <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret

0000000080000a4a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4a:	1101                	addi	sp,sp,-32
    80000a4c:	ec06                	sd	ra,24(sp)
    80000a4e:	e822                	sd	s0,16(sp)
    80000a50:	e426                	sd	s1,8(sp)
    80000a52:	e04a                	sd	s2,0(sp)
    80000a54:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a56:	03451793          	slli	a5,a0,0x34
    80000a5a:	ebb9                	bnez	a5,80000ab0 <kfree+0x66>
    80000a5c:	84aa                	mv	s1,a0
    80000a5e:	00026797          	auipc	a5,0x26
    80000a62:	e1278793          	addi	a5,a5,-494 # 80026870 <end>
    80000a66:	04f56563          	bltu	a0,a5,80000ab0 <kfree+0x66>
    80000a6a:	47c5                	li	a5,17
    80000a6c:	07ee                	slli	a5,a5,0x1b
    80000a6e:	04f57163          	bgeu	a0,a5,80000ab0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a72:	6605                	lui	a2,0x1
    80000a74:	4585                	li	a1,1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2be080e7          	jalr	702(ra) # 80000d34 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00013917          	auipc	s2,0x13
    80000a82:	bc290913          	addi	s2,s2,-1086 # 80013640 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	1b0080e7          	jalr	432(ra) # 80000c38 <acquire>
  r->next = kmem.freelist;
    80000a90:	01893783          	ld	a5,24(s2)
    80000a94:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a96:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	250080e7          	jalr	592(ra) # 80000cec <release>
}
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6902                	ld	s2,0(sp)
    80000aac:	6105                	addi	sp,sp,32
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	59050513          	addi	a0,a0,1424 # 80008040 <etext+0x40>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	aa8080e7          	jalr	-1368(ra) # 80000560 <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	addi	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aca:	6785                	lui	a5,0x1
    80000acc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad0:	00e504b3          	add	s1,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad8:	94be                	add	s1,s1,a5
    80000ada:	0295e463          	bltu	a1,s1,80000b02 <freerange+0x42>
    80000ade:	e84a                	sd	s2,16(sp)
    80000ae0:	e44e                	sd	s3,8(sp)
    80000ae2:	e052                	sd	s4,0(sp)
    80000ae4:	892e                	mv	s2,a1
    kfree(p);
    80000ae6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	6985                	lui	s3,0x1
    kfree(p);
    80000aea:	01448533          	add	a0,s1,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	f5c080e7          	jalr	-164(ra) # 80000a4a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af6:	94ce                	add	s1,s1,s3
    80000af8:	fe9979e3          	bgeu	s2,s1,80000aea <freerange+0x2a>
    80000afc:	6942                	ld	s2,16(sp)
    80000afe:	69a2                	ld	s3,8(sp)
    80000b00:	6a02                	ld	s4,0(sp)
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6145                	addi	sp,sp,48
    80000b0a:	8082                	ret

0000000080000b0c <kinit>:
{
    80000b0c:	1141                	addi	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b14:	00007597          	auipc	a1,0x7
    80000b18:	53458593          	addi	a1,a1,1332 # 80008048 <etext+0x48>
    80000b1c:	00013517          	auipc	a0,0x13
    80000b20:	b2450513          	addi	a0,a0,-1244 # 80013640 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00026517          	auipc	a0,0x26
    80000b34:	d4050513          	addi	a0,a0,-704 # 80026870 <end>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f88080e7          	jalr	-120(ra) # 80000ac0 <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	addi	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00013497          	auipc	s1,0x13
    80000b56:	aee48493          	addi	s1,s1,-1298 # 80013640 <kmem>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	0dc080e7          	jalr	220(ra) # 80000c38 <acquire>
  r = kmem.freelist;
    80000b64:	6c84                	ld	s1,24(s1)
  if(r)
    80000b66:	c885                	beqz	s1,80000b96 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00013517          	auipc	a0,0x13
    80000b6e:	ad650513          	addi	a0,a0,-1322 # 80013640 <kmem>
    80000b72:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	178080e7          	jalr	376(ra) # 80000cec <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4595                	li	a1,5
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	1b2080e7          	jalr	434(ra) # 80000d34 <memset>
  return (void*)r;
}
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	addi	sp,sp,32
    80000b94:	8082                	ret
  release(&kmem.lock);
    80000b96:	00013517          	auipc	a0,0x13
    80000b9a:	aaa50513          	addi	a0,a0,-1366 # 80013640 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	14e080e7          	jalr	334(ra) # 80000cec <release>
  if(r)
    80000ba6:	b7d5                	j	80000b8a <kalloc+0x42>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	addi	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	addi	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	addi	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	e64080e7          	jalr	-412(ra) # 80001a36 <mycpu>
    80000bda:	40a48533          	sub	a0,s1,a0
    80000bde:	00153513          	seqz	a0,a0
}
    80000be2:	60e2                	ld	ra,24(sp)
    80000be4:	6442                	ld	s0,16(sp)
    80000be6:	64a2                	ld	s1,8(sp)
    80000be8:	6105                	addi	sp,sp,32
    80000bea:	8082                	ret

0000000080000bec <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bec:	1101                	addi	sp,sp,-32
    80000bee:	ec06                	sd	ra,24(sp)
    80000bf0:	e822                	sd	s0,16(sp)
    80000bf2:	e426                	sd	s1,8(sp)
    80000bf4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf6:	100024f3          	csrr	s1,sstatus
    80000bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c00:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	e32080e7          	jalr	-462(ra) # 80001a36 <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e26080e7          	jalr	-474(ra) # 80001a36 <mycpu>
    80000c18:	5d3c                	lw	a5,120(a0)
    80000c1a:	2785                	addiw	a5,a5,1
    80000c1c:	dd3c                	sw	a5,120(a0)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    mycpu()->intena = old;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	e0e080e7          	jalr	-498(ra) # 80001a36 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c30:	8085                	srli	s1,s1,0x1
    80000c32:	8885                	andi	s1,s1,1
    80000c34:	dd64                	sw	s1,124(a0)
    80000c36:	bfe9                	j	80000c10 <push_off+0x24>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	addi	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	addi	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	fa8080e7          	jalr	-88(ra) # 80000bec <push_off>
  if(holding(lk))
    80000c4c:	8526                	mv	a0,s1
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	f70080e7          	jalr	-144(ra) # 80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c56:	4705                	li	a4,1
  if(holding(lk))
    80000c58:	e115                	bnez	a0,80000c7c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5a:	87ba                	mv	a5,a4
    80000c5c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c60:	2781                	sext.w	a5,a5
    80000c62:	ffe5                	bnez	a5,80000c5a <acquire+0x22>
  __sync_synchronize();
    80000c64:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	dce080e7          	jalr	-562(ra) # 80001a36 <mycpu>
    80000c70:	e888                	sd	a0,16(s1)
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	addi	sp,sp,32
    80000c7a:	8082                	ret
    panic("acquire");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	3d450513          	addi	a0,a0,980 # 80008050 <etext+0x50>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	addi	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	00001097          	auipc	ra,0x1
    80000c98:	da2080e7          	jalr	-606(ra) # 80001a36 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ca2:	e78d                	bnez	a5,80000ccc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca4:	5d3c                	lw	a5,120(a0)
    80000ca6:	02f05b63          	blez	a5,80000cdc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000caa:	37fd                	addiw	a5,a5,-1
    80000cac:	0007871b          	sext.w	a4,a5
    80000cb0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb2:	eb09                	bnez	a4,80000cc4 <pop_off+0x38>
    80000cb4:	5d7c                	lw	a5,124(a0)
    80000cb6:	c799                	beqz	a5,80000cc4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc4:	60a2                	ld	ra,8(sp)
    80000cc6:	6402                	ld	s0,0(sp)
    80000cc8:	0141                	addi	sp,sp,16
    80000cca:	8082                	ret
    panic("pop_off - interruptible");
    80000ccc:	00007517          	auipc	a0,0x7
    80000cd0:	38c50513          	addi	a0,a0,908 # 80008058 <etext+0x58>
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    panic("pop_off");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39450513          	addi	a0,a0,916 # 80008070 <etext+0x70>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	87c080e7          	jalr	-1924(ra) # 80000560 <panic>

0000000080000cec <release>:
{
    80000cec:	1101                	addi	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	addi	s0,sp,32
    80000cf6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	ec6080e7          	jalr	-314(ra) # 80000bbe <holding>
    80000d00:	c115                	beqz	a0,80000d24 <release+0x38>
  lk->cpu = 0;
    80000d02:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d06:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d0a:	0310000f          	fence	rw,w
    80000d0e:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f7a080e7          	jalr	-134(ra) # 80000c8c <pop_off>
}
    80000d1a:	60e2                	ld	ra,24(sp)
    80000d1c:	6442                	ld	s0,16(sp)
    80000d1e:	64a2                	ld	s1,8(sp)
    80000d20:	6105                	addi	sp,sp,32
    80000d22:	8082                	ret
    panic("release");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	35450513          	addi	a0,a0,852 # 80008078 <etext+0x78>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080000d34 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d34:	1141                	addi	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3a:	ca19                	beqz	a2,80000d50 <memset+0x1c>
    80000d3c:	87aa                	mv	a5,a0
    80000d3e:	1602                	slli	a2,a2,0x20
    80000d40:	9201                	srli	a2,a2,0x20
    80000d42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4a:	0785                	addi	a5,a5,1
    80000d4c:	fee79de3          	bne	a5,a4,80000d46 <memset+0x12>
  }
  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5c:	ca05                	beqz	a2,80000d8c <memcmp+0x36>
    80000d5e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d62:	1682                	slli	a3,a3,0x20
    80000d64:	9281                	srli	a3,a3,0x20
    80000d66:	0685                	addi	a3,a3,1
    80000d68:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	0005c703          	lbu	a4,0(a1)
    80000d72:	00e79863          	bne	a5,a4,80000d82 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d76:	0505                	addi	a0,a0,1
    80000d78:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d7a:	fed518e3          	bne	a0,a3,80000d6a <memcmp+0x14>
  }

  return 0;
    80000d7e:	4501                	li	a0,0
    80000d80:	a019                	j	80000d86 <memcmp+0x30>
      return *s1 - *s2;
    80000d82:	40e7853b          	subw	a0,a5,a4
}
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	addi	sp,sp,16
    80000d8a:	8082                	ret
  return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	bfe5                	j	80000d86 <memcmp+0x30>

0000000080000d90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d90:	1141                	addi	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d96:	c205                	beqz	a2,80000db6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d98:	02a5e263          	bltu	a1,a0,80000dbc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9c:	1602                	slli	a2,a2,0x20
    80000d9e:	9201                	srli	a2,a2,0x20
    80000da0:	00c587b3          	add	a5,a1,a2
{
    80000da4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da6:	0585                	addi	a1,a1,1
    80000da8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd8791>
    80000daa:	fff5c683          	lbu	a3,-1(a1)
    80000dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db2:	feb79ae3          	bne	a5,a1,80000da6 <memmove+0x16>

  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret
  if(s < d && s + n > d){
    80000dbc:	02061693          	slli	a3,a2,0x20
    80000dc0:	9281                	srli	a3,a3,0x20
    80000dc2:	00d58733          	add	a4,a1,a3
    80000dc6:	fce57be3          	bgeu	a0,a4,80000d9c <memmove+0xc>
    d += n;
    80000dca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dcc:	fff6079b          	addiw	a5,a2,-1
    80000dd0:	1782                	slli	a5,a5,0x20
    80000dd2:	9381                	srli	a5,a5,0x20
    80000dd4:	fff7c793          	not	a5,a5
    80000dd8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dda:	177d                	addi	a4,a4,-1
    80000ddc:	16fd                	addi	a3,a3,-1
    80000dde:	00074603          	lbu	a2,0(a4)
    80000de2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de6:	fef71ae3          	bne	a4,a5,80000dda <memmove+0x4a>
    80000dea:	b7f1                	j	80000db6 <memmove+0x26>

0000000080000dec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dec:	1141                	addi	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df4:	00000097          	auipc	ra,0x0
    80000df8:	f9c080e7          	jalr	-100(ra) # 80000d90 <memmove>
}
    80000dfc:	60a2                	ld	ra,8(sp)
    80000dfe:	6402                	ld	s0,0(sp)
    80000e00:	0141                	addi	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e04:	1141                	addi	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0a:	ce11                	beqz	a2,80000e26 <strncmp+0x22>
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf89                	beqz	a5,80000e2a <strncmp+0x26>
    80000e12:	0005c703          	lbu	a4,0(a1)
    80000e16:	00f71a63          	bne	a4,a5,80000e2a <strncmp+0x26>
    n--, p++, q++;
    80000e1a:	367d                	addiw	a2,a2,-1
    80000e1c:	0505                	addi	a0,a0,1
    80000e1e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e20:	f675                	bnez	a2,80000e0c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	a801                	j	80000e34 <strncmp+0x30>
    80000e26:	4501                	li	a0,0
    80000e28:	a031                	j	80000e34 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	addi	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	86b2                	mv	a3,a2
    80000e44:	367d                	addiw	a2,a2,-1
    80000e46:	02d05563          	blez	a3,80000e70 <strncpy+0x36>
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	0585                	addi	a1,a1,1
    80000e56:	f775                	bnez	a4,80000e42 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e58:	873e                	mv	a4,a5
    80000e5a:	9fb5                	addw	a5,a5,a3
    80000e5c:	37fd                	addiw	a5,a5,-1
    80000e5e:	00c05963          	blez	a2,80000e70 <strncpy+0x36>
    *s++ = 0;
    80000e62:	0705                	addi	a4,a4,1
    80000e64:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e68:	40e786bb          	subw	a3,a5,a4
    80000e6c:	fed04be3          	bgtz	a3,80000e62 <strncpy+0x28>
  return os;
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	addi	sp,sp,16
    80000e74:	8082                	ret

0000000080000e76 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e76:	1141                	addi	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7c:	02c05363          	blez	a2,80000ea2 <safestrcpy+0x2c>
    80000e80:	fff6069b          	addiw	a3,a2,-1
    80000e84:	1682                	slli	a3,a3,0x20
    80000e86:	9281                	srli	a3,a3,0x20
    80000e88:	96ae                	add	a3,a3,a1
    80000e8a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8c:	00d58963          	beq	a1,a3,80000e9e <safestrcpy+0x28>
    80000e90:	0585                	addi	a1,a1,1
    80000e92:	0785                	addi	a5,a5,1
    80000e94:	fff5c703          	lbu	a4,-1(a1)
    80000e98:	fee78fa3          	sb	a4,-1(a5)
    80000e9c:	fb65                	bnez	a4,80000e8c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea2:	6422                	ld	s0,8(sp)
    80000ea4:	0141                	addi	sp,sp,16
    80000ea6:	8082                	ret

0000000080000ea8 <strlen>:

int
strlen(const char *s)
{
    80000ea8:	1141                	addi	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eae:	00054783          	lbu	a5,0(a0)
    80000eb2:	cf91                	beqz	a5,80000ece <strlen+0x26>
    80000eb4:	0505                	addi	a0,a0,1
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	86be                	mv	a3,a5
    80000eba:	0785                	addi	a5,a5,1
    80000ebc:	fff7c703          	lbu	a4,-1(a5)
    80000ec0:	ff65                	bnez	a4,80000eb8 <strlen+0x10>
    80000ec2:	40a6853b          	subw	a0,a3,a0
    80000ec6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	addi	sp,sp,16
    80000ecc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <strlen+0x20>

0000000080000ed2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed2:	1141                	addi	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	b4c080e7          	jalr	-1204(ra) # 80001a26 <cpuid>
    sem_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	0000a717          	auipc	a4,0xa
    80000ee6:	4f670713          	addi	a4,a4,1270 # 8000b3d8 <started>
  if(cpuid() == 0){
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while(started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	b30080e7          	jalr	-1232(ra) # 80001a26 <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	19850513          	addi	a0,a0,408 # 80008098 <etext+0x98>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0e0080e7          	jalr	224(ra) # 80000ff0 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f18:	00001097          	auipc	ra,0x1
    80000f1c:	7da080e7          	jalr	2010(ra) # 800026f2 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	16a080e7          	jalr	362(ra) # 8000608a <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	022080e7          	jalr	34(ra) # 80001f4a <scheduler>
    consoleinit();
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	540080e7          	jalr	1344(ra) # 80000470 <consoleinit>
    printfinit();
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	87a080e7          	jalr	-1926(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f40:	00007517          	auipc	a0,0x7
    80000f44:	0d050513          	addi	a0,a0,208 # 80008010 <etext+0x10>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	662080e7          	jalr	1634(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	13050513          	addi	a0,a0,304 # 80008080 <etext+0x80>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	652080e7          	jalr	1618(ra) # 800005aa <printf>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	0b050513          	addi	a0,a0,176 # 80008010 <etext+0x10>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	642080e7          	jalr	1602(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();       // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	32e080e7          	jalr	814(ra) # 800012a6 <kvminit>
    kvminithart();   // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	070080e7          	jalr	112(ra) # 80000ff0 <kvminithart>
    procinit();      // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	9dc080e7          	jalr	-1572(ra) # 80001964 <procinit>
    trapinit();      // trap vectors
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	73a080e7          	jalr	1850(ra) # 800026ca <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00001097          	auipc	ra,0x1
    80000f9c:	75a080e7          	jalr	1882(ra) # 800026f2 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	0d0080e7          	jalr	208(ra) # 80006070 <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	0e2080e7          	jalr	226(ra) # 8000608a <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	f44080e7          	jalr	-188(ra) # 80002ef4 <binit>
    iinit();         // inode table
    80000fb8:	00002097          	auipc	ra,0x2
    80000fbc:	5fa080e7          	jalr	1530(ra) # 800035b2 <iinit>
    fileinit();      // file table
    80000fc0:	00003097          	auipc	ra,0x3
    80000fc4:	5aa080e7          	jalr	1450(ra) # 8000456a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	1ca080e7          	jalr	458(ra) # 80006192 <virtio_disk_init>
    sem_init();
    80000fd0:	00005097          	auipc	ra,0x5
    80000fd4:	e3a080e7          	jalr	-454(ra) # 80005e0a <sem_init>
    userinit();      // first user process
    80000fd8:	00001097          	auipc	ra,0x1
    80000fdc:	d52080e7          	jalr	-686(ra) # 80001d2a <userinit>
    __sync_synchronize();
    80000fe0:	0330000f          	fence	rw,rw
    started = 1;
    80000fe4:	4785                	li	a5,1
    80000fe6:	0000a717          	auipc	a4,0xa
    80000fea:	3ef72923          	sw	a5,1010(a4) # 8000b3d8 <started>
    80000fee:	bf2d                	j	80000f28 <main+0x56>

0000000080000ff0 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000ff0:	1141                	addi	sp,sp,-16
    80000ff2:	e422                	sd	s0,8(sp)
    80000ff4:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ff6:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ffa:	0000a797          	auipc	a5,0xa
    80000ffe:	3e67b783          	ld	a5,998(a5) # 8000b3e0 <kernel_pagetable>
    80001002:	83b1                	srli	a5,a5,0xc
    80001004:	577d                	li	a4,-1
    80001006:	177e                	slli	a4,a4,0x3f
    80001008:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000100a:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000100e:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001012:	6422                	ld	s0,8(sp)
    80001014:	0141                	addi	sp,sp,16
    80001016:	8082                	ret

0000000080001018 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001018:	7139                	addi	sp,sp,-64
    8000101a:	fc06                	sd	ra,56(sp)
    8000101c:	f822                	sd	s0,48(sp)
    8000101e:	f426                	sd	s1,40(sp)
    80001020:	f04a                	sd	s2,32(sp)
    80001022:	ec4e                	sd	s3,24(sp)
    80001024:	e852                	sd	s4,16(sp)
    80001026:	e456                	sd	s5,8(sp)
    80001028:	e05a                	sd	s6,0(sp)
    8000102a:	0080                	addi	s0,sp,64
    8000102c:	84aa                	mv	s1,a0
    8000102e:	89ae                	mv	s3,a1
    80001030:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001032:	57fd                	li	a5,-1
    80001034:	83e9                	srli	a5,a5,0x1a
    80001036:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001038:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000103a:	04b7f263          	bgeu	a5,a1,8000107e <walk+0x66>
    panic("walk");
    8000103e:	00007517          	auipc	a0,0x7
    80001042:	07250513          	addi	a0,a0,114 # 800080b0 <etext+0xb0>
    80001046:	fffff097          	auipc	ra,0xfffff
    8000104a:	51a080e7          	jalr	1306(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000104e:	060a8663          	beqz	s5,800010ba <walk+0xa2>
    80001052:	00000097          	auipc	ra,0x0
    80001056:	af6080e7          	jalr	-1290(ra) # 80000b48 <kalloc>
    8000105a:	84aa                	mv	s1,a0
    8000105c:	c529                	beqz	a0,800010a6 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000105e:	6605                	lui	a2,0x1
    80001060:	4581                	li	a1,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	cd2080e7          	jalr	-814(ra) # 80000d34 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000106a:	00c4d793          	srli	a5,s1,0xc
    8000106e:	07aa                	slli	a5,a5,0xa
    80001070:	0017e793          	ori	a5,a5,1
    80001074:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001078:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd8787>
    8000107a:	036a0063          	beq	s4,s6,8000109a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000107e:	0149d933          	srl	s2,s3,s4
    80001082:	1ff97913          	andi	s2,s2,511
    80001086:	090e                	slli	s2,s2,0x3
    80001088:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000108a:	00093483          	ld	s1,0(s2)
    8000108e:	0014f793          	andi	a5,s1,1
    80001092:	dfd5                	beqz	a5,8000104e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001094:	80a9                	srli	s1,s1,0xa
    80001096:	04b2                	slli	s1,s1,0xc
    80001098:	b7c5                	j	80001078 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000109a:	00c9d513          	srli	a0,s3,0xc
    8000109e:	1ff57513          	andi	a0,a0,511
    800010a2:	050e                	slli	a0,a0,0x3
    800010a4:	9526                	add	a0,a0,s1
}
    800010a6:	70e2                	ld	ra,56(sp)
    800010a8:	7442                	ld	s0,48(sp)
    800010aa:	74a2                	ld	s1,40(sp)
    800010ac:	7902                	ld	s2,32(sp)
    800010ae:	69e2                	ld	s3,24(sp)
    800010b0:	6a42                	ld	s4,16(sp)
    800010b2:	6aa2                	ld	s5,8(sp)
    800010b4:	6b02                	ld	s6,0(sp)
    800010b6:	6121                	addi	sp,sp,64
    800010b8:	8082                	ret
        return 0;
    800010ba:	4501                	li	a0,0
    800010bc:	b7ed                	j	800010a6 <walk+0x8e>

00000000800010be <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010be:	57fd                	li	a5,-1
    800010c0:	83e9                	srli	a5,a5,0x1a
    800010c2:	00b7f463          	bgeu	a5,a1,800010ca <walkaddr+0xc>
    return 0;
    800010c6:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c8:	8082                	ret
{
    800010ca:	1141                	addi	sp,sp,-16
    800010cc:	e406                	sd	ra,8(sp)
    800010ce:	e022                	sd	s0,0(sp)
    800010d0:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010d2:	4601                	li	a2,0
    800010d4:	00000097          	auipc	ra,0x0
    800010d8:	f44080e7          	jalr	-188(ra) # 80001018 <walk>
  if(pte == 0)
    800010dc:	c105                	beqz	a0,800010fc <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010de:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010e0:	0117f693          	andi	a3,a5,17
    800010e4:	4745                	li	a4,17
    return 0;
    800010e6:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e8:	00e68663          	beq	a3,a4,800010f4 <walkaddr+0x36>
}
    800010ec:	60a2                	ld	ra,8(sp)
    800010ee:	6402                	ld	s0,0(sp)
    800010f0:	0141                	addi	sp,sp,16
    800010f2:	8082                	ret
  pa = PTE2PA(*pte);
    800010f4:	83a9                	srli	a5,a5,0xa
    800010f6:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010fa:	bfcd                	j	800010ec <walkaddr+0x2e>
    return 0;
    800010fc:	4501                	li	a0,0
    800010fe:	b7fd                	j	800010ec <walkaddr+0x2e>

0000000080001100 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001100:	715d                	addi	sp,sp,-80
    80001102:	e486                	sd	ra,72(sp)
    80001104:	e0a2                	sd	s0,64(sp)
    80001106:	fc26                	sd	s1,56(sp)
    80001108:	f84a                	sd	s2,48(sp)
    8000110a:	f44e                	sd	s3,40(sp)
    8000110c:	f052                	sd	s4,32(sp)
    8000110e:	ec56                	sd	s5,24(sp)
    80001110:	e85a                	sd	s6,16(sp)
    80001112:	e45e                	sd	s7,8(sp)
    80001114:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001116:	c639                	beqz	a2,80001164 <mappages+0x64>
    80001118:	8aaa                	mv	s5,a0
    8000111a:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000111c:	777d                	lui	a4,0xfffff
    8000111e:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001122:	fff58993          	addi	s3,a1,-1
    80001126:	99b2                	add	s3,s3,a2
    80001128:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000112c:	893e                	mv	s2,a5
    8000112e:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001132:	6b85                	lui	s7,0x1
    80001134:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001138:	4605                	li	a2,1
    8000113a:	85ca                	mv	a1,s2
    8000113c:	8556                	mv	a0,s5
    8000113e:	00000097          	auipc	ra,0x0
    80001142:	eda080e7          	jalr	-294(ra) # 80001018 <walk>
    80001146:	cd1d                	beqz	a0,80001184 <mappages+0x84>
    if(*pte & PTE_V)
    80001148:	611c                	ld	a5,0(a0)
    8000114a:	8b85                	andi	a5,a5,1
    8000114c:	e785                	bnez	a5,80001174 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000114e:	80b1                	srli	s1,s1,0xc
    80001150:	04aa                	slli	s1,s1,0xa
    80001152:	0164e4b3          	or	s1,s1,s6
    80001156:	0014e493          	ori	s1,s1,1
    8000115a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000115c:	05390063          	beq	s2,s3,8000119c <mappages+0x9c>
    a += PGSIZE;
    80001160:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001162:	bfc9                	j	80001134 <mappages+0x34>
    panic("mappages: size");
    80001164:	00007517          	auipc	a0,0x7
    80001168:	f5450513          	addi	a0,a0,-172 # 800080b8 <etext+0xb8>
    8000116c:	fffff097          	auipc	ra,0xfffff
    80001170:	3f4080e7          	jalr	1012(ra) # 80000560 <panic>
      panic("mappages: remap");
    80001174:	00007517          	auipc	a0,0x7
    80001178:	f5450513          	addi	a0,a0,-172 # 800080c8 <etext+0xc8>
    8000117c:	fffff097          	auipc	ra,0xfffff
    80001180:	3e4080e7          	jalr	996(ra) # 80000560 <panic>
      return -1;
    80001184:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001186:	60a6                	ld	ra,72(sp)
    80001188:	6406                	ld	s0,64(sp)
    8000118a:	74e2                	ld	s1,56(sp)
    8000118c:	7942                	ld	s2,48(sp)
    8000118e:	79a2                	ld	s3,40(sp)
    80001190:	7a02                	ld	s4,32(sp)
    80001192:	6ae2                	ld	s5,24(sp)
    80001194:	6b42                	ld	s6,16(sp)
    80001196:	6ba2                	ld	s7,8(sp)
    80001198:	6161                	addi	sp,sp,80
    8000119a:	8082                	ret
  return 0;
    8000119c:	4501                	li	a0,0
    8000119e:	b7e5                	j	80001186 <mappages+0x86>

00000000800011a0 <kvmmap>:
{
    800011a0:	1141                	addi	sp,sp,-16
    800011a2:	e406                	sd	ra,8(sp)
    800011a4:	e022                	sd	s0,0(sp)
    800011a6:	0800                	addi	s0,sp,16
    800011a8:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011aa:	86b2                	mv	a3,a2
    800011ac:	863e                	mv	a2,a5
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f52080e7          	jalr	-174(ra) # 80001100 <mappages>
    800011b6:	e509                	bnez	a0,800011c0 <kvmmap+0x20>
}
    800011b8:	60a2                	ld	ra,8(sp)
    800011ba:	6402                	ld	s0,0(sp)
    800011bc:	0141                	addi	sp,sp,16
    800011be:	8082                	ret
    panic("kvmmap");
    800011c0:	00007517          	auipc	a0,0x7
    800011c4:	f1850513          	addi	a0,a0,-232 # 800080d8 <etext+0xd8>
    800011c8:	fffff097          	auipc	ra,0xfffff
    800011cc:	398080e7          	jalr	920(ra) # 80000560 <panic>

00000000800011d0 <kvmmake>:
{
    800011d0:	1101                	addi	sp,sp,-32
    800011d2:	ec06                	sd	ra,24(sp)
    800011d4:	e822                	sd	s0,16(sp)
    800011d6:	e426                	sd	s1,8(sp)
    800011d8:	e04a                	sd	s2,0(sp)
    800011da:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011dc:	00000097          	auipc	ra,0x0
    800011e0:	96c080e7          	jalr	-1684(ra) # 80000b48 <kalloc>
    800011e4:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011e6:	6605                	lui	a2,0x1
    800011e8:	4581                	li	a1,0
    800011ea:	00000097          	auipc	ra,0x0
    800011ee:	b4a080e7          	jalr	-1206(ra) # 80000d34 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011f2:	4719                	li	a4,6
    800011f4:	6685                	lui	a3,0x1
    800011f6:	10000637          	lui	a2,0x10000
    800011fa:	100005b7          	lui	a1,0x10000
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	fa0080e7          	jalr	-96(ra) # 800011a0 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	6685                	lui	a3,0x1
    8000120c:	10001637          	lui	a2,0x10001
    80001210:	100015b7          	lui	a1,0x10001
    80001214:	8526                	mv	a0,s1
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	f8a080e7          	jalr	-118(ra) # 800011a0 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000121e:	4719                	li	a4,6
    80001220:	004006b7          	lui	a3,0x400
    80001224:	0c000637          	lui	a2,0xc000
    80001228:	0c0005b7          	lui	a1,0xc000
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	f72080e7          	jalr	-142(ra) # 800011a0 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001236:	00007917          	auipc	s2,0x7
    8000123a:	dca90913          	addi	s2,s2,-566 # 80008000 <etext>
    8000123e:	4729                	li	a4,10
    80001240:	80007697          	auipc	a3,0x80007
    80001244:	dc068693          	addi	a3,a3,-576 # 8000 <_entry-0x7fff8000>
    80001248:	4605                	li	a2,1
    8000124a:	067e                	slli	a2,a2,0x1f
    8000124c:	85b2                	mv	a1,a2
    8000124e:	8526                	mv	a0,s1
    80001250:	00000097          	auipc	ra,0x0
    80001254:	f50080e7          	jalr	-176(ra) # 800011a0 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001258:	46c5                	li	a3,17
    8000125a:	06ee                	slli	a3,a3,0x1b
    8000125c:	4719                	li	a4,6
    8000125e:	412686b3          	sub	a3,a3,s2
    80001262:	864a                	mv	a2,s2
    80001264:	85ca                	mv	a1,s2
    80001266:	8526                	mv	a0,s1
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	f38080e7          	jalr	-200(ra) # 800011a0 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001270:	4729                	li	a4,10
    80001272:	6685                	lui	a3,0x1
    80001274:	00006617          	auipc	a2,0x6
    80001278:	d8c60613          	addi	a2,a2,-628 # 80007000 <_trampoline>
    8000127c:	040005b7          	lui	a1,0x4000
    80001280:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001282:	05b2                	slli	a1,a1,0xc
    80001284:	8526                	mv	a0,s1
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	f1a080e7          	jalr	-230(ra) # 800011a0 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000128e:	8526                	mv	a0,s1
    80001290:	00000097          	auipc	ra,0x0
    80001294:	630080e7          	jalr	1584(ra) # 800018c0 <proc_mapstacks>
}
    80001298:	8526                	mv	a0,s1
    8000129a:	60e2                	ld	ra,24(sp)
    8000129c:	6442                	ld	s0,16(sp)
    8000129e:	64a2                	ld	s1,8(sp)
    800012a0:	6902                	ld	s2,0(sp)
    800012a2:	6105                	addi	sp,sp,32
    800012a4:	8082                	ret

00000000800012a6 <kvminit>:
{
    800012a6:	1141                	addi	sp,sp,-16
    800012a8:	e406                	sd	ra,8(sp)
    800012aa:	e022                	sd	s0,0(sp)
    800012ac:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	f22080e7          	jalr	-222(ra) # 800011d0 <kvmmake>
    800012b6:	0000a797          	auipc	a5,0xa
    800012ba:	12a7b523          	sd	a0,298(a5) # 8000b3e0 <kernel_pagetable>
}
    800012be:	60a2                	ld	ra,8(sp)
    800012c0:	6402                	ld	s0,0(sp)
    800012c2:	0141                	addi	sp,sp,16
    800012c4:	8082                	ret

00000000800012c6 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012c6:	715d                	addi	sp,sp,-80
    800012c8:	e486                	sd	ra,72(sp)
    800012ca:	e0a2                	sd	s0,64(sp)
    800012cc:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012ce:	03459793          	slli	a5,a1,0x34
    800012d2:	e39d                	bnez	a5,800012f8 <uvmunmap+0x32>
    800012d4:	f84a                	sd	s2,48(sp)
    800012d6:	f44e                	sd	s3,40(sp)
    800012d8:	f052                	sd	s4,32(sp)
    800012da:	ec56                	sd	s5,24(sp)
    800012dc:	e85a                	sd	s6,16(sp)
    800012de:	e45e                	sd	s7,8(sp)
    800012e0:	8a2a                	mv	s4,a0
    800012e2:	892e                	mv	s2,a1
    800012e4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	0632                	slli	a2,a2,0xc
    800012e8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ec:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	6b05                	lui	s6,0x1
    800012f0:	0935fb63          	bgeu	a1,s3,80001386 <uvmunmap+0xc0>
    800012f4:	fc26                	sd	s1,56(sp)
    800012f6:	a8a9                	j	80001350 <uvmunmap+0x8a>
    800012f8:	fc26                	sd	s1,56(sp)
    800012fa:	f84a                	sd	s2,48(sp)
    800012fc:	f44e                	sd	s3,40(sp)
    800012fe:	f052                	sd	s4,32(sp)
    80001300:	ec56                	sd	s5,24(sp)
    80001302:	e85a                	sd	s6,16(sp)
    80001304:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001306:	00007517          	auipc	a0,0x7
    8000130a:	dda50513          	addi	a0,a0,-550 # 800080e0 <etext+0xe0>
    8000130e:	fffff097          	auipc	ra,0xfffff
    80001312:	252080e7          	jalr	594(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    80001316:	00007517          	auipc	a0,0x7
    8000131a:	de250513          	addi	a0,a0,-542 # 800080f8 <etext+0xf8>
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	242080e7          	jalr	578(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    80001326:	00007517          	auipc	a0,0x7
    8000132a:	de250513          	addi	a0,a0,-542 # 80008108 <etext+0x108>
    8000132e:	fffff097          	auipc	ra,0xfffff
    80001332:	232080e7          	jalr	562(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    80001336:	00007517          	auipc	a0,0x7
    8000133a:	dea50513          	addi	a0,a0,-534 # 80008120 <etext+0x120>
    8000133e:	fffff097          	auipc	ra,0xfffff
    80001342:	222080e7          	jalr	546(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001346:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000134a:	995a                	add	s2,s2,s6
    8000134c:	03397c63          	bgeu	s2,s3,80001384 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001350:	4601                	li	a2,0
    80001352:	85ca                	mv	a1,s2
    80001354:	8552                	mv	a0,s4
    80001356:	00000097          	auipc	ra,0x0
    8000135a:	cc2080e7          	jalr	-830(ra) # 80001018 <walk>
    8000135e:	84aa                	mv	s1,a0
    80001360:	d95d                	beqz	a0,80001316 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001362:	6108                	ld	a0,0(a0)
    80001364:	00157793          	andi	a5,a0,1
    80001368:	dfdd                	beqz	a5,80001326 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000136a:	3ff57793          	andi	a5,a0,1023
    8000136e:	fd7784e3          	beq	a5,s7,80001336 <uvmunmap+0x70>
    if(do_free){
    80001372:	fc0a8ae3          	beqz	s5,80001346 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001376:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001378:	0532                	slli	a0,a0,0xc
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	6d0080e7          	jalr	1744(ra) # 80000a4a <kfree>
    80001382:	b7d1                	j	80001346 <uvmunmap+0x80>
    80001384:	74e2                	ld	s1,56(sp)
    80001386:	7942                	ld	s2,48(sp)
    80001388:	79a2                	ld	s3,40(sp)
    8000138a:	7a02                	ld	s4,32(sp)
    8000138c:	6ae2                	ld	s5,24(sp)
    8000138e:	6b42                	ld	s6,16(sp)
    80001390:	6ba2                	ld	s7,8(sp)
  }
}
    80001392:	60a6                	ld	ra,72(sp)
    80001394:	6406                	ld	s0,64(sp)
    80001396:	6161                	addi	sp,sp,80
    80001398:	8082                	ret

000000008000139a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000139a:	1101                	addi	sp,sp,-32
    8000139c:	ec06                	sd	ra,24(sp)
    8000139e:	e822                	sd	s0,16(sp)
    800013a0:	e426                	sd	s1,8(sp)
    800013a2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013a4:	fffff097          	auipc	ra,0xfffff
    800013a8:	7a4080e7          	jalr	1956(ra) # 80000b48 <kalloc>
    800013ac:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013ae:	c519                	beqz	a0,800013bc <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013b0:	6605                	lui	a2,0x1
    800013b2:	4581                	li	a1,0
    800013b4:	00000097          	auipc	ra,0x0
    800013b8:	980080e7          	jalr	-1664(ra) # 80000d34 <memset>
  return pagetable;
}
    800013bc:	8526                	mv	a0,s1
    800013be:	60e2                	ld	ra,24(sp)
    800013c0:	6442                	ld	s0,16(sp)
    800013c2:	64a2                	ld	s1,8(sp)
    800013c4:	6105                	addi	sp,sp,32
    800013c6:	8082                	ret

00000000800013c8 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c8:	7179                	addi	sp,sp,-48
    800013ca:	f406                	sd	ra,40(sp)
    800013cc:	f022                	sd	s0,32(sp)
    800013ce:	ec26                	sd	s1,24(sp)
    800013d0:	e84a                	sd	s2,16(sp)
    800013d2:	e44e                	sd	s3,8(sp)
    800013d4:	e052                	sd	s4,0(sp)
    800013d6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d8:	6785                	lui	a5,0x1
    800013da:	04f67863          	bgeu	a2,a5,8000142a <uvmfirst+0x62>
    800013de:	8a2a                	mv	s4,a0
    800013e0:	89ae                	mv	s3,a1
    800013e2:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013e4:	fffff097          	auipc	ra,0xfffff
    800013e8:	764080e7          	jalr	1892(ra) # 80000b48 <kalloc>
    800013ec:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013ee:	6605                	lui	a2,0x1
    800013f0:	4581                	li	a1,0
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	942080e7          	jalr	-1726(ra) # 80000d34 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013fa:	4779                	li	a4,30
    800013fc:	86ca                	mv	a3,s2
    800013fe:	6605                	lui	a2,0x1
    80001400:	4581                	li	a1,0
    80001402:	8552                	mv	a0,s4
    80001404:	00000097          	auipc	ra,0x0
    80001408:	cfc080e7          	jalr	-772(ra) # 80001100 <mappages>
  memmove(mem, src, sz);
    8000140c:	8626                	mv	a2,s1
    8000140e:	85ce                	mv	a1,s3
    80001410:	854a                	mv	a0,s2
    80001412:	00000097          	auipc	ra,0x0
    80001416:	97e080e7          	jalr	-1666(ra) # 80000d90 <memmove>
}
    8000141a:	70a2                	ld	ra,40(sp)
    8000141c:	7402                	ld	s0,32(sp)
    8000141e:	64e2                	ld	s1,24(sp)
    80001420:	6942                	ld	s2,16(sp)
    80001422:	69a2                	ld	s3,8(sp)
    80001424:	6a02                	ld	s4,0(sp)
    80001426:	6145                	addi	sp,sp,48
    80001428:	8082                	ret
    panic("uvmfirst: more than a page");
    8000142a:	00007517          	auipc	a0,0x7
    8000142e:	d0e50513          	addi	a0,a0,-754 # 80008138 <etext+0x138>
    80001432:	fffff097          	auipc	ra,0xfffff
    80001436:	12e080e7          	jalr	302(ra) # 80000560 <panic>

000000008000143a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000143a:	1101                	addi	sp,sp,-32
    8000143c:	ec06                	sd	ra,24(sp)
    8000143e:	e822                	sd	s0,16(sp)
    80001440:	e426                	sd	s1,8(sp)
    80001442:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001444:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001446:	00b67d63          	bgeu	a2,a1,80001460 <uvmdealloc+0x26>
    8000144a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000144c:	6785                	lui	a5,0x1
    8000144e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001450:	00f60733          	add	a4,a2,a5
    80001454:	76fd                	lui	a3,0xfffff
    80001456:	8f75                	and	a4,a4,a3
    80001458:	97ae                	add	a5,a5,a1
    8000145a:	8ff5                	and	a5,a5,a3
    8000145c:	00f76863          	bltu	a4,a5,8000146c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001460:	8526                	mv	a0,s1
    80001462:	60e2                	ld	ra,24(sp)
    80001464:	6442                	ld	s0,16(sp)
    80001466:	64a2                	ld	s1,8(sp)
    80001468:	6105                	addi	sp,sp,32
    8000146a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000146c:	8f99                	sub	a5,a5,a4
    8000146e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001470:	4685                	li	a3,1
    80001472:	0007861b          	sext.w	a2,a5
    80001476:	85ba                	mv	a1,a4
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	e4e080e7          	jalr	-434(ra) # 800012c6 <uvmunmap>
    80001480:	b7c5                	j	80001460 <uvmdealloc+0x26>

0000000080001482 <uvmalloc>:
  if(newsz < oldsz)
    80001482:	0ab66b63          	bltu	a2,a1,80001538 <uvmalloc+0xb6>
{
    80001486:	7139                	addi	sp,sp,-64
    80001488:	fc06                	sd	ra,56(sp)
    8000148a:	f822                	sd	s0,48(sp)
    8000148c:	ec4e                	sd	s3,24(sp)
    8000148e:	e852                	sd	s4,16(sp)
    80001490:	e456                	sd	s5,8(sp)
    80001492:	0080                	addi	s0,sp,64
    80001494:	8aaa                	mv	s5,a0
    80001496:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001498:	6785                	lui	a5,0x1
    8000149a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000149c:	95be                	add	a1,a1,a5
    8000149e:	77fd                	lui	a5,0xfffff
    800014a0:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014a4:	08c9fc63          	bgeu	s3,a2,8000153c <uvmalloc+0xba>
    800014a8:	f426                	sd	s1,40(sp)
    800014aa:	f04a                	sd	s2,32(sp)
    800014ac:	e05a                	sd	s6,0(sp)
    800014ae:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014b0:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014b4:	fffff097          	auipc	ra,0xfffff
    800014b8:	694080e7          	jalr	1684(ra) # 80000b48 <kalloc>
    800014bc:	84aa                	mv	s1,a0
    if(mem == 0){
    800014be:	c915                	beqz	a0,800014f2 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014c0:	6605                	lui	a2,0x1
    800014c2:	4581                	li	a1,0
    800014c4:	00000097          	auipc	ra,0x0
    800014c8:	870080e7          	jalr	-1936(ra) # 80000d34 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014cc:	875a                	mv	a4,s6
    800014ce:	86a6                	mv	a3,s1
    800014d0:	6605                	lui	a2,0x1
    800014d2:	85ca                	mv	a1,s2
    800014d4:	8556                	mv	a0,s5
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	c2a080e7          	jalr	-982(ra) # 80001100 <mappages>
    800014de:	ed05                	bnez	a0,80001516 <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014e0:	6785                	lui	a5,0x1
    800014e2:	993e                	add	s2,s2,a5
    800014e4:	fd4968e3          	bltu	s2,s4,800014b4 <uvmalloc+0x32>
  return newsz;
    800014e8:	8552                	mv	a0,s4
    800014ea:	74a2                	ld	s1,40(sp)
    800014ec:	7902                	ld	s2,32(sp)
    800014ee:	6b02                	ld	s6,0(sp)
    800014f0:	a821                	j	80001508 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014f2:	864e                	mv	a2,s3
    800014f4:	85ca                	mv	a1,s2
    800014f6:	8556                	mv	a0,s5
    800014f8:	00000097          	auipc	ra,0x0
    800014fc:	f42080e7          	jalr	-190(ra) # 8000143a <uvmdealloc>
      return 0;
    80001500:	4501                	li	a0,0
    80001502:	74a2                	ld	s1,40(sp)
    80001504:	7902                	ld	s2,32(sp)
    80001506:	6b02                	ld	s6,0(sp)
}
    80001508:	70e2                	ld	ra,56(sp)
    8000150a:	7442                	ld	s0,48(sp)
    8000150c:	69e2                	ld	s3,24(sp)
    8000150e:	6a42                	ld	s4,16(sp)
    80001510:	6aa2                	ld	s5,8(sp)
    80001512:	6121                	addi	sp,sp,64
    80001514:	8082                	ret
      kfree(mem);
    80001516:	8526                	mv	a0,s1
    80001518:	fffff097          	auipc	ra,0xfffff
    8000151c:	532080e7          	jalr	1330(ra) # 80000a4a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001520:	864e                	mv	a2,s3
    80001522:	85ca                	mv	a1,s2
    80001524:	8556                	mv	a0,s5
    80001526:	00000097          	auipc	ra,0x0
    8000152a:	f14080e7          	jalr	-236(ra) # 8000143a <uvmdealloc>
      return 0;
    8000152e:	4501                	li	a0,0
    80001530:	74a2                	ld	s1,40(sp)
    80001532:	7902                	ld	s2,32(sp)
    80001534:	6b02                	ld	s6,0(sp)
    80001536:	bfc9                	j	80001508 <uvmalloc+0x86>
    return oldsz;
    80001538:	852e                	mv	a0,a1
}
    8000153a:	8082                	ret
  return newsz;
    8000153c:	8532                	mv	a0,a2
    8000153e:	b7e9                	j	80001508 <uvmalloc+0x86>

0000000080001540 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001540:	7179                	addi	sp,sp,-48
    80001542:	f406                	sd	ra,40(sp)
    80001544:	f022                	sd	s0,32(sp)
    80001546:	ec26                	sd	s1,24(sp)
    80001548:	e84a                	sd	s2,16(sp)
    8000154a:	e44e                	sd	s3,8(sp)
    8000154c:	e052                	sd	s4,0(sp)
    8000154e:	1800                	addi	s0,sp,48
    80001550:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001552:	84aa                	mv	s1,a0
    80001554:	6905                	lui	s2,0x1
    80001556:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001558:	4985                	li	s3,1
    8000155a:	a829                	j	80001574 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000155c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000155e:	00c79513          	slli	a0,a5,0xc
    80001562:	00000097          	auipc	ra,0x0
    80001566:	fde080e7          	jalr	-34(ra) # 80001540 <freewalk>
      pagetable[i] = 0;
    8000156a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000156e:	04a1                	addi	s1,s1,8
    80001570:	03248163          	beq	s1,s2,80001592 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001574:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001576:	00f7f713          	andi	a4,a5,15
    8000157a:	ff3701e3          	beq	a4,s3,8000155c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000157e:	8b85                	andi	a5,a5,1
    80001580:	d7fd                	beqz	a5,8000156e <freewalk+0x2e>
      panic("freewalk: leaf");
    80001582:	00007517          	auipc	a0,0x7
    80001586:	bd650513          	addi	a0,a0,-1066 # 80008158 <etext+0x158>
    8000158a:	fffff097          	auipc	ra,0xfffff
    8000158e:	fd6080e7          	jalr	-42(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    80001592:	8552                	mv	a0,s4
    80001594:	fffff097          	auipc	ra,0xfffff
    80001598:	4b6080e7          	jalr	1206(ra) # 80000a4a <kfree>
}
    8000159c:	70a2                	ld	ra,40(sp)
    8000159e:	7402                	ld	s0,32(sp)
    800015a0:	64e2                	ld	s1,24(sp)
    800015a2:	6942                	ld	s2,16(sp)
    800015a4:	69a2                	ld	s3,8(sp)
    800015a6:	6a02                	ld	s4,0(sp)
    800015a8:	6145                	addi	sp,sp,48
    800015aa:	8082                	ret

00000000800015ac <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015ac:	1101                	addi	sp,sp,-32
    800015ae:	ec06                	sd	ra,24(sp)
    800015b0:	e822                	sd	s0,16(sp)
    800015b2:	e426                	sd	s1,8(sp)
    800015b4:	1000                	addi	s0,sp,32
    800015b6:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b8:	e999                	bnez	a1,800015ce <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015ba:	8526                	mv	a0,s1
    800015bc:	00000097          	auipc	ra,0x0
    800015c0:	f84080e7          	jalr	-124(ra) # 80001540 <freewalk>
}
    800015c4:	60e2                	ld	ra,24(sp)
    800015c6:	6442                	ld	s0,16(sp)
    800015c8:	64a2                	ld	s1,8(sp)
    800015ca:	6105                	addi	sp,sp,32
    800015cc:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015ce:	6785                	lui	a5,0x1
    800015d0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015d2:	95be                	add	a1,a1,a5
    800015d4:	4685                	li	a3,1
    800015d6:	00c5d613          	srli	a2,a1,0xc
    800015da:	4581                	li	a1,0
    800015dc:	00000097          	auipc	ra,0x0
    800015e0:	cea080e7          	jalr	-790(ra) # 800012c6 <uvmunmap>
    800015e4:	bfd9                	j	800015ba <uvmfree+0xe>

00000000800015e6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015e6:	c679                	beqz	a2,800016b4 <uvmcopy+0xce>
{
    800015e8:	715d                	addi	sp,sp,-80
    800015ea:	e486                	sd	ra,72(sp)
    800015ec:	e0a2                	sd	s0,64(sp)
    800015ee:	fc26                	sd	s1,56(sp)
    800015f0:	f84a                	sd	s2,48(sp)
    800015f2:	f44e                	sd	s3,40(sp)
    800015f4:	f052                	sd	s4,32(sp)
    800015f6:	ec56                	sd	s5,24(sp)
    800015f8:	e85a                	sd	s6,16(sp)
    800015fa:	e45e                	sd	s7,8(sp)
    800015fc:	0880                	addi	s0,sp,80
    800015fe:	8b2a                	mv	s6,a0
    80001600:	8aae                	mv	s5,a1
    80001602:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001604:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001606:	4601                	li	a2,0
    80001608:	85ce                	mv	a1,s3
    8000160a:	855a                	mv	a0,s6
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	a0c080e7          	jalr	-1524(ra) # 80001018 <walk>
    80001614:	c531                	beqz	a0,80001660 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001616:	6118                	ld	a4,0(a0)
    80001618:	00177793          	andi	a5,a4,1
    8000161c:	cbb1                	beqz	a5,80001670 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000161e:	00a75593          	srli	a1,a4,0xa
    80001622:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001626:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000162a:	fffff097          	auipc	ra,0xfffff
    8000162e:	51e080e7          	jalr	1310(ra) # 80000b48 <kalloc>
    80001632:	892a                	mv	s2,a0
    80001634:	c939                	beqz	a0,8000168a <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001636:	6605                	lui	a2,0x1
    80001638:	85de                	mv	a1,s7
    8000163a:	fffff097          	auipc	ra,0xfffff
    8000163e:	756080e7          	jalr	1878(ra) # 80000d90 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001642:	8726                	mv	a4,s1
    80001644:	86ca                	mv	a3,s2
    80001646:	6605                	lui	a2,0x1
    80001648:	85ce                	mv	a1,s3
    8000164a:	8556                	mv	a0,s5
    8000164c:	00000097          	auipc	ra,0x0
    80001650:	ab4080e7          	jalr	-1356(ra) # 80001100 <mappages>
    80001654:	e515                	bnez	a0,80001680 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001656:	6785                	lui	a5,0x1
    80001658:	99be                	add	s3,s3,a5
    8000165a:	fb49e6e3          	bltu	s3,s4,80001606 <uvmcopy+0x20>
    8000165e:	a081                	j	8000169e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001660:	00007517          	auipc	a0,0x7
    80001664:	b0850513          	addi	a0,a0,-1272 # 80008168 <etext+0x168>
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	ef8080e7          	jalr	-264(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001670:	00007517          	auipc	a0,0x7
    80001674:	b1850513          	addi	a0,a0,-1256 # 80008188 <etext+0x188>
    80001678:	fffff097          	auipc	ra,0xfffff
    8000167c:	ee8080e7          	jalr	-280(ra) # 80000560 <panic>
      kfree(mem);
    80001680:	854a                	mv	a0,s2
    80001682:	fffff097          	auipc	ra,0xfffff
    80001686:	3c8080e7          	jalr	968(ra) # 80000a4a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000168a:	4685                	li	a3,1
    8000168c:	00c9d613          	srli	a2,s3,0xc
    80001690:	4581                	li	a1,0
    80001692:	8556                	mv	a0,s5
    80001694:	00000097          	auipc	ra,0x0
    80001698:	c32080e7          	jalr	-974(ra) # 800012c6 <uvmunmap>
  return -1;
    8000169c:	557d                	li	a0,-1
}
    8000169e:	60a6                	ld	ra,72(sp)
    800016a0:	6406                	ld	s0,64(sp)
    800016a2:	74e2                	ld	s1,56(sp)
    800016a4:	7942                	ld	s2,48(sp)
    800016a6:	79a2                	ld	s3,40(sp)
    800016a8:	7a02                	ld	s4,32(sp)
    800016aa:	6ae2                	ld	s5,24(sp)
    800016ac:	6b42                	ld	s6,16(sp)
    800016ae:	6ba2                	ld	s7,8(sp)
    800016b0:	6161                	addi	sp,sp,80
    800016b2:	8082                	ret
  return 0;
    800016b4:	4501                	li	a0,0
}
    800016b6:	8082                	ret

00000000800016b8 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b8:	1141                	addi	sp,sp,-16
    800016ba:	e406                	sd	ra,8(sp)
    800016bc:	e022                	sd	s0,0(sp)
    800016be:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016c0:	4601                	li	a2,0
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	956080e7          	jalr	-1706(ra) # 80001018 <walk>
  if(pte == 0)
    800016ca:	c901                	beqz	a0,800016da <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016cc:	611c                	ld	a5,0(a0)
    800016ce:	9bbd                	andi	a5,a5,-17
    800016d0:	e11c                	sd	a5,0(a0)
}
    800016d2:	60a2                	ld	ra,8(sp)
    800016d4:	6402                	ld	s0,0(sp)
    800016d6:	0141                	addi	sp,sp,16
    800016d8:	8082                	ret
    panic("uvmclear");
    800016da:	00007517          	auipc	a0,0x7
    800016de:	ace50513          	addi	a0,a0,-1330 # 800081a8 <etext+0x1a8>
    800016e2:	fffff097          	auipc	ra,0xfffff
    800016e6:	e7e080e7          	jalr	-386(ra) # 80000560 <panic>

00000000800016ea <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ea:	c6bd                	beqz	a3,80001758 <copyout+0x6e>
{
    800016ec:	715d                	addi	sp,sp,-80
    800016ee:	e486                	sd	ra,72(sp)
    800016f0:	e0a2                	sd	s0,64(sp)
    800016f2:	fc26                	sd	s1,56(sp)
    800016f4:	f84a                	sd	s2,48(sp)
    800016f6:	f44e                	sd	s3,40(sp)
    800016f8:	f052                	sd	s4,32(sp)
    800016fa:	ec56                	sd	s5,24(sp)
    800016fc:	e85a                	sd	s6,16(sp)
    800016fe:	e45e                	sd	s7,8(sp)
    80001700:	e062                	sd	s8,0(sp)
    80001702:	0880                	addi	s0,sp,80
    80001704:	8b2a                	mv	s6,a0
    80001706:	8c2e                	mv	s8,a1
    80001708:	8a32                	mv	s4,a2
    8000170a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000170c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000170e:	6a85                	lui	s5,0x1
    80001710:	a015                	j	80001734 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001712:	9562                	add	a0,a0,s8
    80001714:	0004861b          	sext.w	a2,s1
    80001718:	85d2                	mv	a1,s4
    8000171a:	41250533          	sub	a0,a0,s2
    8000171e:	fffff097          	auipc	ra,0xfffff
    80001722:	672080e7          	jalr	1650(ra) # 80000d90 <memmove>

    len -= n;
    80001726:	409989b3          	sub	s3,s3,s1
    src += n;
    8000172a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000172c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001730:	02098263          	beqz	s3,80001754 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001734:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001738:	85ca                	mv	a1,s2
    8000173a:	855a                	mv	a0,s6
    8000173c:	00000097          	auipc	ra,0x0
    80001740:	982080e7          	jalr	-1662(ra) # 800010be <walkaddr>
    if(pa0 == 0)
    80001744:	cd01                	beqz	a0,8000175c <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001746:	418904b3          	sub	s1,s2,s8
    8000174a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000174c:	fc99f3e3          	bgeu	s3,s1,80001712 <copyout+0x28>
    80001750:	84ce                	mv	s1,s3
    80001752:	b7c1                	j	80001712 <copyout+0x28>
  }
  return 0;
    80001754:	4501                	li	a0,0
    80001756:	a021                	j	8000175e <copyout+0x74>
    80001758:	4501                	li	a0,0
}
    8000175a:	8082                	ret
      return -1;
    8000175c:	557d                	li	a0,-1
}
    8000175e:	60a6                	ld	ra,72(sp)
    80001760:	6406                	ld	s0,64(sp)
    80001762:	74e2                	ld	s1,56(sp)
    80001764:	7942                	ld	s2,48(sp)
    80001766:	79a2                	ld	s3,40(sp)
    80001768:	7a02                	ld	s4,32(sp)
    8000176a:	6ae2                	ld	s5,24(sp)
    8000176c:	6b42                	ld	s6,16(sp)
    8000176e:	6ba2                	ld	s7,8(sp)
    80001770:	6c02                	ld	s8,0(sp)
    80001772:	6161                	addi	sp,sp,80
    80001774:	8082                	ret

0000000080001776 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001776:	caa5                	beqz	a3,800017e6 <copyin+0x70>
{
    80001778:	715d                	addi	sp,sp,-80
    8000177a:	e486                	sd	ra,72(sp)
    8000177c:	e0a2                	sd	s0,64(sp)
    8000177e:	fc26                	sd	s1,56(sp)
    80001780:	f84a                	sd	s2,48(sp)
    80001782:	f44e                	sd	s3,40(sp)
    80001784:	f052                	sd	s4,32(sp)
    80001786:	ec56                	sd	s5,24(sp)
    80001788:	e85a                	sd	s6,16(sp)
    8000178a:	e45e                	sd	s7,8(sp)
    8000178c:	e062                	sd	s8,0(sp)
    8000178e:	0880                	addi	s0,sp,80
    80001790:	8b2a                	mv	s6,a0
    80001792:	8a2e                	mv	s4,a1
    80001794:	8c32                	mv	s8,a2
    80001796:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001798:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000179a:	6a85                	lui	s5,0x1
    8000179c:	a01d                	j	800017c2 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000179e:	018505b3          	add	a1,a0,s8
    800017a2:	0004861b          	sext.w	a2,s1
    800017a6:	412585b3          	sub	a1,a1,s2
    800017aa:	8552                	mv	a0,s4
    800017ac:	fffff097          	auipc	ra,0xfffff
    800017b0:	5e4080e7          	jalr	1508(ra) # 80000d90 <memmove>

    len -= n;
    800017b4:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b8:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017ba:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017be:	02098263          	beqz	s3,800017e2 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017c2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017c6:	85ca                	mv	a1,s2
    800017c8:	855a                	mv	a0,s6
    800017ca:	00000097          	auipc	ra,0x0
    800017ce:	8f4080e7          	jalr	-1804(ra) # 800010be <walkaddr>
    if(pa0 == 0)
    800017d2:	cd01                	beqz	a0,800017ea <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017d4:	418904b3          	sub	s1,s2,s8
    800017d8:	94d6                	add	s1,s1,s5
    if(n > len)
    800017da:	fc99f2e3          	bgeu	s3,s1,8000179e <copyin+0x28>
    800017de:	84ce                	mv	s1,s3
    800017e0:	bf7d                	j	8000179e <copyin+0x28>
  }
  return 0;
    800017e2:	4501                	li	a0,0
    800017e4:	a021                	j	800017ec <copyin+0x76>
    800017e6:	4501                	li	a0,0
}
    800017e8:	8082                	ret
      return -1;
    800017ea:	557d                	li	a0,-1
}
    800017ec:	60a6                	ld	ra,72(sp)
    800017ee:	6406                	ld	s0,64(sp)
    800017f0:	74e2                	ld	s1,56(sp)
    800017f2:	7942                	ld	s2,48(sp)
    800017f4:	79a2                	ld	s3,40(sp)
    800017f6:	7a02                	ld	s4,32(sp)
    800017f8:	6ae2                	ld	s5,24(sp)
    800017fa:	6b42                	ld	s6,16(sp)
    800017fc:	6ba2                	ld	s7,8(sp)
    800017fe:	6c02                	ld	s8,0(sp)
    80001800:	6161                	addi	sp,sp,80
    80001802:	8082                	ret

0000000080001804 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001804:	cacd                	beqz	a3,800018b6 <copyinstr+0xb2>
{
    80001806:	715d                	addi	sp,sp,-80
    80001808:	e486                	sd	ra,72(sp)
    8000180a:	e0a2                	sd	s0,64(sp)
    8000180c:	fc26                	sd	s1,56(sp)
    8000180e:	f84a                	sd	s2,48(sp)
    80001810:	f44e                	sd	s3,40(sp)
    80001812:	f052                	sd	s4,32(sp)
    80001814:	ec56                	sd	s5,24(sp)
    80001816:	e85a                	sd	s6,16(sp)
    80001818:	e45e                	sd	s7,8(sp)
    8000181a:	0880                	addi	s0,sp,80
    8000181c:	8a2a                	mv	s4,a0
    8000181e:	8b2e                	mv	s6,a1
    80001820:	8bb2                	mv	s7,a2
    80001822:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001824:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001826:	6985                	lui	s3,0x1
    80001828:	a825                	j	80001860 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000182a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000182e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001830:	37fd                	addiw	a5,a5,-1
    80001832:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001836:	60a6                	ld	ra,72(sp)
    80001838:	6406                	ld	s0,64(sp)
    8000183a:	74e2                	ld	s1,56(sp)
    8000183c:	7942                	ld	s2,48(sp)
    8000183e:	79a2                	ld	s3,40(sp)
    80001840:	7a02                	ld	s4,32(sp)
    80001842:	6ae2                	ld	s5,24(sp)
    80001844:	6b42                	ld	s6,16(sp)
    80001846:	6ba2                	ld	s7,8(sp)
    80001848:	6161                	addi	sp,sp,80
    8000184a:	8082                	ret
    8000184c:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001850:	9742                	add	a4,a4,a6
      --max;
    80001852:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001856:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000185a:	04e58663          	beq	a1,a4,800018a6 <copyinstr+0xa2>
{
    8000185e:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001860:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001864:	85a6                	mv	a1,s1
    80001866:	8552                	mv	a0,s4
    80001868:	00000097          	auipc	ra,0x0
    8000186c:	856080e7          	jalr	-1962(ra) # 800010be <walkaddr>
    if(pa0 == 0)
    80001870:	cd0d                	beqz	a0,800018aa <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001872:	417486b3          	sub	a3,s1,s7
    80001876:	96ce                	add	a3,a3,s3
    if(n > max)
    80001878:	00d97363          	bgeu	s2,a3,8000187e <copyinstr+0x7a>
    8000187c:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    8000187e:	955e                	add	a0,a0,s7
    80001880:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001882:	c695                	beqz	a3,800018ae <copyinstr+0xaa>
    80001884:	87da                	mv	a5,s6
    80001886:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001888:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000188c:	96da                	add	a3,a3,s6
    8000188e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001890:	00f60733          	add	a4,a2,a5
    80001894:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8790>
    80001898:	db49                	beqz	a4,8000182a <copyinstr+0x26>
        *dst = *p;
    8000189a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000189e:	0785                	addi	a5,a5,1
    while(n > 0){
    800018a0:	fed797e3          	bne	a5,a3,8000188e <copyinstr+0x8a>
    800018a4:	b765                	j	8000184c <copyinstr+0x48>
    800018a6:	4781                	li	a5,0
    800018a8:	b761                	j	80001830 <copyinstr+0x2c>
      return -1;
    800018aa:	557d                	li	a0,-1
    800018ac:	b769                	j	80001836 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018ae:	6b85                	lui	s7,0x1
    800018b0:	9ba6                	add	s7,s7,s1
    800018b2:	87da                	mv	a5,s6
    800018b4:	b76d                	j	8000185e <copyinstr+0x5a>
  int got_null = 0;
    800018b6:	4781                	li	a5,0
  if(got_null){
    800018b8:	37fd                	addiw	a5,a5,-1
    800018ba:	0007851b          	sext.w	a0,a5
}
    800018be:	8082                	ret

00000000800018c0 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018c0:	7139                	addi	sp,sp,-64
    800018c2:	fc06                	sd	ra,56(sp)
    800018c4:	f822                	sd	s0,48(sp)
    800018c6:	f426                	sd	s1,40(sp)
    800018c8:	f04a                	sd	s2,32(sp)
    800018ca:	ec4e                	sd	s3,24(sp)
    800018cc:	e852                	sd	s4,16(sp)
    800018ce:	e456                	sd	s5,8(sp)
    800018d0:	e05a                	sd	s6,0(sp)
    800018d2:	0080                	addi	s0,sp,64
    800018d4:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018d6:	00012497          	auipc	s1,0x12
    800018da:	1ba48493          	addi	s1,s1,442 # 80013a90 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018de:	8b26                	mv	s6,s1
    800018e0:	04fa5937          	lui	s2,0x4fa5
    800018e4:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800018e8:	0932                	slli	s2,s2,0xc
    800018ea:	fa590913          	addi	s2,s2,-91
    800018ee:	0932                	slli	s2,s2,0xc
    800018f0:	fa590913          	addi	s2,s2,-91
    800018f4:	0932                	slli	s2,s2,0xc
    800018f6:	fa590913          	addi	s2,s2,-91
    800018fa:	040009b7          	lui	s3,0x4000
    800018fe:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001900:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001902:	00018a97          	auipc	s5,0x18
    80001906:	b8ea8a93          	addi	s5,s5,-1138 # 80019490 <tickslock>
    char *pa = kalloc();
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	23e080e7          	jalr	574(ra) # 80000b48 <kalloc>
    80001912:	862a                	mv	a2,a0
    if(pa == 0)
    80001914:	c121                	beqz	a0,80001954 <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    80001916:	416485b3          	sub	a1,s1,s6
    8000191a:	858d                	srai	a1,a1,0x3
    8000191c:	032585b3          	mul	a1,a1,s2
    80001920:	2585                	addiw	a1,a1,1
    80001922:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001926:	4719                	li	a4,6
    80001928:	6685                	lui	a3,0x1
    8000192a:	40b985b3          	sub	a1,s3,a1
    8000192e:	8552                	mv	a0,s4
    80001930:	00000097          	auipc	ra,0x0
    80001934:	870080e7          	jalr	-1936(ra) # 800011a0 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001938:	16848493          	addi	s1,s1,360
    8000193c:	fd5497e3          	bne	s1,s5,8000190a <proc_mapstacks+0x4a>
  }
}
    80001940:	70e2                	ld	ra,56(sp)
    80001942:	7442                	ld	s0,48(sp)
    80001944:	74a2                	ld	s1,40(sp)
    80001946:	7902                	ld	s2,32(sp)
    80001948:	69e2                	ld	s3,24(sp)
    8000194a:	6a42                	ld	s4,16(sp)
    8000194c:	6aa2                	ld	s5,8(sp)
    8000194e:	6b02                	ld	s6,0(sp)
    80001950:	6121                	addi	sp,sp,64
    80001952:	8082                	ret
      panic("kalloc");
    80001954:	00007517          	auipc	a0,0x7
    80001958:	86450513          	addi	a0,a0,-1948 # 800081b8 <etext+0x1b8>
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	c04080e7          	jalr	-1020(ra) # 80000560 <panic>

0000000080001964 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001964:	7139                	addi	sp,sp,-64
    80001966:	fc06                	sd	ra,56(sp)
    80001968:	f822                	sd	s0,48(sp)
    8000196a:	f426                	sd	s1,40(sp)
    8000196c:	f04a                	sd	s2,32(sp)
    8000196e:	ec4e                	sd	s3,24(sp)
    80001970:	e852                	sd	s4,16(sp)
    80001972:	e456                	sd	s5,8(sp)
    80001974:	e05a                	sd	s6,0(sp)
    80001976:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001978:	00007597          	auipc	a1,0x7
    8000197c:	84858593          	addi	a1,a1,-1976 # 800081c0 <etext+0x1c0>
    80001980:	00012517          	auipc	a0,0x12
    80001984:	ce050513          	addi	a0,a0,-800 # 80013660 <pid_lock>
    80001988:	fffff097          	auipc	ra,0xfffff
    8000198c:	220080e7          	jalr	544(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001990:	00007597          	auipc	a1,0x7
    80001994:	83858593          	addi	a1,a1,-1992 # 800081c8 <etext+0x1c8>
    80001998:	00012517          	auipc	a0,0x12
    8000199c:	ce050513          	addi	a0,a0,-800 # 80013678 <wait_lock>
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	208080e7          	jalr	520(ra) # 80000ba8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a8:	00012497          	auipc	s1,0x12
    800019ac:	0e848493          	addi	s1,s1,232 # 80013a90 <proc>
      initlock(&p->lock, "proc");
    800019b0:	00007b17          	auipc	s6,0x7
    800019b4:	828b0b13          	addi	s6,s6,-2008 # 800081d8 <etext+0x1d8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800019b8:	8aa6                	mv	s5,s1
    800019ba:	04fa5937          	lui	s2,0x4fa5
    800019be:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800019c2:	0932                	slli	s2,s2,0xc
    800019c4:	fa590913          	addi	s2,s2,-91
    800019c8:	0932                	slli	s2,s2,0xc
    800019ca:	fa590913          	addi	s2,s2,-91
    800019ce:	0932                	slli	s2,s2,0xc
    800019d0:	fa590913          	addi	s2,s2,-91
    800019d4:	040009b7          	lui	s3,0x4000
    800019d8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019da:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019dc:	00018a17          	auipc	s4,0x18
    800019e0:	ab4a0a13          	addi	s4,s4,-1356 # 80019490 <tickslock>
      initlock(&p->lock, "proc");
    800019e4:	85da                	mv	a1,s6
    800019e6:	8526                	mv	a0,s1
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	1c0080e7          	jalr	448(ra) # 80000ba8 <initlock>
      p->state = UNUSED;
    800019f0:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019f4:	415487b3          	sub	a5,s1,s5
    800019f8:	878d                	srai	a5,a5,0x3
    800019fa:	032787b3          	mul	a5,a5,s2
    800019fe:	2785                	addiw	a5,a5,1
    80001a00:	00d7979b          	slliw	a5,a5,0xd
    80001a04:	40f987b3          	sub	a5,s3,a5
    80001a08:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a0a:	16848493          	addi	s1,s1,360
    80001a0e:	fd449be3          	bne	s1,s4,800019e4 <procinit+0x80>
  }
}
    80001a12:	70e2                	ld	ra,56(sp)
    80001a14:	7442                	ld	s0,48(sp)
    80001a16:	74a2                	ld	s1,40(sp)
    80001a18:	7902                	ld	s2,32(sp)
    80001a1a:	69e2                	ld	s3,24(sp)
    80001a1c:	6a42                	ld	s4,16(sp)
    80001a1e:	6aa2                	ld	s5,8(sp)
    80001a20:	6b02                	ld	s6,0(sp)
    80001a22:	6121                	addi	sp,sp,64
    80001a24:	8082                	ret

0000000080001a26 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a26:	1141                	addi	sp,sp,-16
    80001a28:	e422                	sd	s0,8(sp)
    80001a2a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a2c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a2e:	2501                	sext.w	a0,a0
    80001a30:	6422                	ld	s0,8(sp)
    80001a32:	0141                	addi	sp,sp,16
    80001a34:	8082                	ret

0000000080001a36 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a36:	1141                	addi	sp,sp,-16
    80001a38:	e422                	sd	s0,8(sp)
    80001a3a:	0800                	addi	s0,sp,16
    80001a3c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a3e:	2781                	sext.w	a5,a5
    80001a40:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a42:	00012517          	auipc	a0,0x12
    80001a46:	c4e50513          	addi	a0,a0,-946 # 80013690 <cpus>
    80001a4a:	953e                	add	a0,a0,a5
    80001a4c:	6422                	ld	s0,8(sp)
    80001a4e:	0141                	addi	sp,sp,16
    80001a50:	8082                	ret

0000000080001a52 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
  push_off();
    80001a5c:	fffff097          	auipc	ra,0xfffff
    80001a60:	190080e7          	jalr	400(ra) # 80000bec <push_off>
    80001a64:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a66:	2781                	sext.w	a5,a5
    80001a68:	079e                	slli	a5,a5,0x7
    80001a6a:	00012717          	auipc	a4,0x12
    80001a6e:	bf670713          	addi	a4,a4,-1034 # 80013660 <pid_lock>
    80001a72:	97ba                	add	a5,a5,a4
    80001a74:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	216080e7          	jalr	534(ra) # 80000c8c <pop_off>
  return p;
}
    80001a7e:	8526                	mv	a0,s1
    80001a80:	60e2                	ld	ra,24(sp)
    80001a82:	6442                	ld	s0,16(sp)
    80001a84:	64a2                	ld	s1,8(sp)
    80001a86:	6105                	addi	sp,sp,32
    80001a88:	8082                	ret

0000000080001a8a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a8a:	1141                	addi	sp,sp,-16
    80001a8c:	e406                	sd	ra,8(sp)
    80001a8e:	e022                	sd	s0,0(sp)
    80001a90:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a92:	00000097          	auipc	ra,0x0
    80001a96:	fc0080e7          	jalr	-64(ra) # 80001a52 <myproc>
    80001a9a:	fffff097          	auipc	ra,0xfffff
    80001a9e:	252080e7          	jalr	594(ra) # 80000cec <release>

  if (first) {
    80001aa2:	0000a797          	auipc	a5,0xa
    80001aa6:	8ae7a783          	lw	a5,-1874(a5) # 8000b350 <first.1>
    80001aaa:	eb89                	bnez	a5,80001abc <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aac:	00001097          	auipc	ra,0x1
    80001ab0:	c5e080e7          	jalr	-930(ra) # 8000270a <usertrapret>
}
    80001ab4:	60a2                	ld	ra,8(sp)
    80001ab6:	6402                	ld	s0,0(sp)
    80001ab8:	0141                	addi	sp,sp,16
    80001aba:	8082                	ret
    first = 0;
    80001abc:	0000a797          	auipc	a5,0xa
    80001ac0:	8807aa23          	sw	zero,-1900(a5) # 8000b350 <first.1>
    fsinit(ROOTDEV);
    80001ac4:	4505                	li	a0,1
    80001ac6:	00002097          	auipc	ra,0x2
    80001aca:	a6c080e7          	jalr	-1428(ra) # 80003532 <fsinit>
    80001ace:	bff9                	j	80001aac <forkret+0x22>

0000000080001ad0 <allocpid>:
{
    80001ad0:	1101                	addi	sp,sp,-32
    80001ad2:	ec06                	sd	ra,24(sp)
    80001ad4:	e822                	sd	s0,16(sp)
    80001ad6:	e426                	sd	s1,8(sp)
    80001ad8:	e04a                	sd	s2,0(sp)
    80001ada:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001adc:	00012917          	auipc	s2,0x12
    80001ae0:	b8490913          	addi	s2,s2,-1148 # 80013660 <pid_lock>
    80001ae4:	854a                	mv	a0,s2
    80001ae6:	fffff097          	auipc	ra,0xfffff
    80001aea:	152080e7          	jalr	338(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001aee:	0000a797          	auipc	a5,0xa
    80001af2:	86678793          	addi	a5,a5,-1946 # 8000b354 <nextpid>
    80001af6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af8:	0014871b          	addiw	a4,s1,1
    80001afc:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001afe:	854a                	mv	a0,s2
    80001b00:	fffff097          	auipc	ra,0xfffff
    80001b04:	1ec080e7          	jalr	492(ra) # 80000cec <release>
}
    80001b08:	8526                	mv	a0,s1
    80001b0a:	60e2                	ld	ra,24(sp)
    80001b0c:	6442                	ld	s0,16(sp)
    80001b0e:	64a2                	ld	s1,8(sp)
    80001b10:	6902                	ld	s2,0(sp)
    80001b12:	6105                	addi	sp,sp,32
    80001b14:	8082                	ret

0000000080001b16 <proc_pagetable>:
{
    80001b16:	1101                	addi	sp,sp,-32
    80001b18:	ec06                	sd	ra,24(sp)
    80001b1a:	e822                	sd	s0,16(sp)
    80001b1c:	e426                	sd	s1,8(sp)
    80001b1e:	e04a                	sd	s2,0(sp)
    80001b20:	1000                	addi	s0,sp,32
    80001b22:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b24:	00000097          	auipc	ra,0x0
    80001b28:	876080e7          	jalr	-1930(ra) # 8000139a <uvmcreate>
    80001b2c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b2e:	c121                	beqz	a0,80001b6e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b30:	4729                	li	a4,10
    80001b32:	00005697          	auipc	a3,0x5
    80001b36:	4ce68693          	addi	a3,a3,1230 # 80007000 <_trampoline>
    80001b3a:	6605                	lui	a2,0x1
    80001b3c:	040005b7          	lui	a1,0x4000
    80001b40:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b42:	05b2                	slli	a1,a1,0xc
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	5bc080e7          	jalr	1468(ra) # 80001100 <mappages>
    80001b4c:	02054863          	bltz	a0,80001b7c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b50:	4719                	li	a4,6
    80001b52:	05893683          	ld	a3,88(s2)
    80001b56:	6605                	lui	a2,0x1
    80001b58:	020005b7          	lui	a1,0x2000
    80001b5c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b5e:	05b6                	slli	a1,a1,0xd
    80001b60:	8526                	mv	a0,s1
    80001b62:	fffff097          	auipc	ra,0xfffff
    80001b66:	59e080e7          	jalr	1438(ra) # 80001100 <mappages>
    80001b6a:	02054163          	bltz	a0,80001b8c <proc_pagetable+0x76>
}
    80001b6e:	8526                	mv	a0,s1
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6902                	ld	s2,0(sp)
    80001b78:	6105                	addi	sp,sp,32
    80001b7a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b7c:	4581                	li	a1,0
    80001b7e:	8526                	mv	a0,s1
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	a2c080e7          	jalr	-1492(ra) # 800015ac <uvmfree>
    return 0;
    80001b88:	4481                	li	s1,0
    80001b8a:	b7d5                	j	80001b6e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b8c:	4681                	li	a3,0
    80001b8e:	4605                	li	a2,1
    80001b90:	040005b7          	lui	a1,0x4000
    80001b94:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b96:	05b2                	slli	a1,a1,0xc
    80001b98:	8526                	mv	a0,s1
    80001b9a:	fffff097          	auipc	ra,0xfffff
    80001b9e:	72c080e7          	jalr	1836(ra) # 800012c6 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ba2:	4581                	li	a1,0
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	00000097          	auipc	ra,0x0
    80001baa:	a06080e7          	jalr	-1530(ra) # 800015ac <uvmfree>
    return 0;
    80001bae:	4481                	li	s1,0
    80001bb0:	bf7d                	j	80001b6e <proc_pagetable+0x58>

0000000080001bb2 <proc_freepagetable>:
{
    80001bb2:	1101                	addi	sp,sp,-32
    80001bb4:	ec06                	sd	ra,24(sp)
    80001bb6:	e822                	sd	s0,16(sp)
    80001bb8:	e426                	sd	s1,8(sp)
    80001bba:	e04a                	sd	s2,0(sp)
    80001bbc:	1000                	addi	s0,sp,32
    80001bbe:	84aa                	mv	s1,a0
    80001bc0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bc2:	4681                	li	a3,0
    80001bc4:	4605                	li	a2,1
    80001bc6:	040005b7          	lui	a1,0x4000
    80001bca:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bcc:	05b2                	slli	a1,a1,0xc
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	6f8080e7          	jalr	1784(ra) # 800012c6 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bd6:	4681                	li	a3,0
    80001bd8:	4605                	li	a2,1
    80001bda:	020005b7          	lui	a1,0x2000
    80001bde:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001be0:	05b6                	slli	a1,a1,0xd
    80001be2:	8526                	mv	a0,s1
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	6e2080e7          	jalr	1762(ra) # 800012c6 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bec:	85ca                	mv	a1,s2
    80001bee:	8526                	mv	a0,s1
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	9bc080e7          	jalr	-1604(ra) # 800015ac <uvmfree>
}
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6902                	ld	s2,0(sp)
    80001c00:	6105                	addi	sp,sp,32
    80001c02:	8082                	ret

0000000080001c04 <freeproc>:
{
    80001c04:	1101                	addi	sp,sp,-32
    80001c06:	ec06                	sd	ra,24(sp)
    80001c08:	e822                	sd	s0,16(sp)
    80001c0a:	e426                	sd	s1,8(sp)
    80001c0c:	1000                	addi	s0,sp,32
    80001c0e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c10:	6d28                	ld	a0,88(a0)
    80001c12:	c509                	beqz	a0,80001c1c <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	e36080e7          	jalr	-458(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c1c:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c20:	68a8                	ld	a0,80(s1)
    80001c22:	c511                	beqz	a0,80001c2e <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c24:	64ac                	ld	a1,72(s1)
    80001c26:	00000097          	auipc	ra,0x0
    80001c2a:	f8c080e7          	jalr	-116(ra) # 80001bb2 <proc_freepagetable>
  p->pagetable = 0;
    80001c2e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c32:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c36:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c3a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c3e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c42:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c46:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c4a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c4e:	0004ac23          	sw	zero,24(s1)
}
    80001c52:	60e2                	ld	ra,24(sp)
    80001c54:	6442                	ld	s0,16(sp)
    80001c56:	64a2                	ld	s1,8(sp)
    80001c58:	6105                	addi	sp,sp,32
    80001c5a:	8082                	ret

0000000080001c5c <allocproc>:
{
    80001c5c:	1101                	addi	sp,sp,-32
    80001c5e:	ec06                	sd	ra,24(sp)
    80001c60:	e822                	sd	s0,16(sp)
    80001c62:	e426                	sd	s1,8(sp)
    80001c64:	e04a                	sd	s2,0(sp)
    80001c66:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c68:	00012497          	auipc	s1,0x12
    80001c6c:	e2848493          	addi	s1,s1,-472 # 80013a90 <proc>
    80001c70:	00018917          	auipc	s2,0x18
    80001c74:	82090913          	addi	s2,s2,-2016 # 80019490 <tickslock>
    acquire(&p->lock);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	fbe080e7          	jalr	-66(ra) # 80000c38 <acquire>
    if(p->state == UNUSED) {
    80001c82:	4c9c                	lw	a5,24(s1)
    80001c84:	cf81                	beqz	a5,80001c9c <allocproc+0x40>
      release(&p->lock);
    80001c86:	8526                	mv	a0,s1
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	064080e7          	jalr	100(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c90:	16848493          	addi	s1,s1,360
    80001c94:	ff2492e3          	bne	s1,s2,80001c78 <allocproc+0x1c>
  return 0;
    80001c98:	4481                	li	s1,0
    80001c9a:	a889                	j	80001cec <allocproc+0x90>
  p->pid = allocpid();
    80001c9c:	00000097          	auipc	ra,0x0
    80001ca0:	e34080e7          	jalr	-460(ra) # 80001ad0 <allocpid>
    80001ca4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ca6:	4785                	li	a5,1
    80001ca8:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	e9e080e7          	jalr	-354(ra) # 80000b48 <kalloc>
    80001cb2:	892a                	mv	s2,a0
    80001cb4:	eca8                	sd	a0,88(s1)
    80001cb6:	c131                	beqz	a0,80001cfa <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	00000097          	auipc	ra,0x0
    80001cbe:	e5c080e7          	jalr	-420(ra) # 80001b16 <proc_pagetable>
    80001cc2:	892a                	mv	s2,a0
    80001cc4:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cc6:	c531                	beqz	a0,80001d12 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cc8:	07000613          	li	a2,112
    80001ccc:	4581                	li	a1,0
    80001cce:	06048513          	addi	a0,s1,96
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	062080e7          	jalr	98(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001cda:	00000797          	auipc	a5,0x0
    80001cde:	db078793          	addi	a5,a5,-592 # 80001a8a <forkret>
    80001ce2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ce4:	60bc                	ld	a5,64(s1)
    80001ce6:	6705                	lui	a4,0x1
    80001ce8:	97ba                	add	a5,a5,a4
    80001cea:	f4bc                	sd	a5,104(s1)
}
    80001cec:	8526                	mv	a0,s1
    80001cee:	60e2                	ld	ra,24(sp)
    80001cf0:	6442                	ld	s0,16(sp)
    80001cf2:	64a2                	ld	s1,8(sp)
    80001cf4:	6902                	ld	s2,0(sp)
    80001cf6:	6105                	addi	sp,sp,32
    80001cf8:	8082                	ret
    freeproc(p);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	00000097          	auipc	ra,0x0
    80001d00:	f08080e7          	jalr	-248(ra) # 80001c04 <freeproc>
    release(&p->lock);
    80001d04:	8526                	mv	a0,s1
    80001d06:	fffff097          	auipc	ra,0xfffff
    80001d0a:	fe6080e7          	jalr	-26(ra) # 80000cec <release>
    return 0;
    80001d0e:	84ca                	mv	s1,s2
    80001d10:	bff1                	j	80001cec <allocproc+0x90>
    freeproc(p);
    80001d12:	8526                	mv	a0,s1
    80001d14:	00000097          	auipc	ra,0x0
    80001d18:	ef0080e7          	jalr	-272(ra) # 80001c04 <freeproc>
    release(&p->lock);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	fce080e7          	jalr	-50(ra) # 80000cec <release>
    return 0;
    80001d26:	84ca                	mv	s1,s2
    80001d28:	b7d1                	j	80001cec <allocproc+0x90>

0000000080001d2a <userinit>:
{
    80001d2a:	1101                	addi	sp,sp,-32
    80001d2c:	ec06                	sd	ra,24(sp)
    80001d2e:	e822                	sd	s0,16(sp)
    80001d30:	e426                	sd	s1,8(sp)
    80001d32:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d34:	00000097          	auipc	ra,0x0
    80001d38:	f28080e7          	jalr	-216(ra) # 80001c5c <allocproc>
    80001d3c:	84aa                	mv	s1,a0
  initproc = p;
    80001d3e:	00009797          	auipc	a5,0x9
    80001d42:	6aa7b523          	sd	a0,1706(a5) # 8000b3e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d46:	03400613          	li	a2,52
    80001d4a:	00009597          	auipc	a1,0x9
    80001d4e:	61658593          	addi	a1,a1,1558 # 8000b360 <initcode>
    80001d52:	6928                	ld	a0,80(a0)
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	674080e7          	jalr	1652(ra) # 800013c8 <uvmfirst>
  p->sz = PGSIZE;
    80001d5c:	6785                	lui	a5,0x1
    80001d5e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d60:	6cb8                	ld	a4,88(s1)
    80001d62:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d66:	6cb8                	ld	a4,88(s1)
    80001d68:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d6a:	4641                	li	a2,16
    80001d6c:	00006597          	auipc	a1,0x6
    80001d70:	47458593          	addi	a1,a1,1140 # 800081e0 <etext+0x1e0>
    80001d74:	15848513          	addi	a0,s1,344
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	0fe080e7          	jalr	254(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001d80:	00006517          	auipc	a0,0x6
    80001d84:	47050513          	addi	a0,a0,1136 # 800081f0 <etext+0x1f0>
    80001d88:	00002097          	auipc	ra,0x2
    80001d8c:	1fc080e7          	jalr	508(ra) # 80003f84 <namei>
    80001d90:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d94:	478d                	li	a5,3
    80001d96:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d98:	8526                	mv	a0,s1
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	f52080e7          	jalr	-174(ra) # 80000cec <release>
}
    80001da2:	60e2                	ld	ra,24(sp)
    80001da4:	6442                	ld	s0,16(sp)
    80001da6:	64a2                	ld	s1,8(sp)
    80001da8:	6105                	addi	sp,sp,32
    80001daa:	8082                	ret

0000000080001dac <growproc>:
{
    80001dac:	1101                	addi	sp,sp,-32
    80001dae:	ec06                	sd	ra,24(sp)
    80001db0:	e822                	sd	s0,16(sp)
    80001db2:	e426                	sd	s1,8(sp)
    80001db4:	e04a                	sd	s2,0(sp)
    80001db6:	1000                	addi	s0,sp,32
    80001db8:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001dba:	00000097          	auipc	ra,0x0
    80001dbe:	c98080e7          	jalr	-872(ra) # 80001a52 <myproc>
    80001dc2:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dc4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dc6:	01204c63          	bgtz	s2,80001dde <growproc+0x32>
  } else if(n < 0){
    80001dca:	02094663          	bltz	s2,80001df6 <growproc+0x4a>
  p->sz = sz;
    80001dce:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dd0:	4501                	li	a0,0
}
    80001dd2:	60e2                	ld	ra,24(sp)
    80001dd4:	6442                	ld	s0,16(sp)
    80001dd6:	64a2                	ld	s1,8(sp)
    80001dd8:	6902                	ld	s2,0(sp)
    80001dda:	6105                	addi	sp,sp,32
    80001ddc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dde:	4691                	li	a3,4
    80001de0:	00b90633          	add	a2,s2,a1
    80001de4:	6928                	ld	a0,80(a0)
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	69c080e7          	jalr	1692(ra) # 80001482 <uvmalloc>
    80001dee:	85aa                	mv	a1,a0
    80001df0:	fd79                	bnez	a0,80001dce <growproc+0x22>
      return -1;
    80001df2:	557d                	li	a0,-1
    80001df4:	bff9                	j	80001dd2 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df6:	00b90633          	add	a2,s2,a1
    80001dfa:	6928                	ld	a0,80(a0)
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	63e080e7          	jalr	1598(ra) # 8000143a <uvmdealloc>
    80001e04:	85aa                	mv	a1,a0
    80001e06:	b7e1                	j	80001dce <growproc+0x22>

0000000080001e08 <fork>:
{
    80001e08:	7139                	addi	sp,sp,-64
    80001e0a:	fc06                	sd	ra,56(sp)
    80001e0c:	f822                	sd	s0,48(sp)
    80001e0e:	f04a                	sd	s2,32(sp)
    80001e10:	e456                	sd	s5,8(sp)
    80001e12:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	c3e080e7          	jalr	-962(ra) # 80001a52 <myproc>
    80001e1c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	e3e080e7          	jalr	-450(ra) # 80001c5c <allocproc>
    80001e26:	12050063          	beqz	a0,80001f46 <fork+0x13e>
    80001e2a:	e852                	sd	s4,16(sp)
    80001e2c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e2e:	048ab603          	ld	a2,72(s5)
    80001e32:	692c                	ld	a1,80(a0)
    80001e34:	050ab503          	ld	a0,80(s5)
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	7ae080e7          	jalr	1966(ra) # 800015e6 <uvmcopy>
    80001e40:	04054a63          	bltz	a0,80001e94 <fork+0x8c>
    80001e44:	f426                	sd	s1,40(sp)
    80001e46:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e48:	048ab783          	ld	a5,72(s5)
    80001e4c:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e50:	058ab683          	ld	a3,88(s5)
    80001e54:	87b6                	mv	a5,a3
    80001e56:	058a3703          	ld	a4,88(s4)
    80001e5a:	12068693          	addi	a3,a3,288
    80001e5e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e62:	6788                	ld	a0,8(a5)
    80001e64:	6b8c                	ld	a1,16(a5)
    80001e66:	6f90                	ld	a2,24(a5)
    80001e68:	01073023          	sd	a6,0(a4)
    80001e6c:	e708                	sd	a0,8(a4)
    80001e6e:	eb0c                	sd	a1,16(a4)
    80001e70:	ef10                	sd	a2,24(a4)
    80001e72:	02078793          	addi	a5,a5,32
    80001e76:	02070713          	addi	a4,a4,32
    80001e7a:	fed792e3          	bne	a5,a3,80001e5e <fork+0x56>
  np->trapframe->a0 = 0;
    80001e7e:	058a3783          	ld	a5,88(s4)
    80001e82:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e86:	0d0a8493          	addi	s1,s5,208
    80001e8a:	0d0a0913          	addi	s2,s4,208
    80001e8e:	150a8993          	addi	s3,s5,336
    80001e92:	a015                	j	80001eb6 <fork+0xae>
    freeproc(np);
    80001e94:	8552                	mv	a0,s4
    80001e96:	00000097          	auipc	ra,0x0
    80001e9a:	d6e080e7          	jalr	-658(ra) # 80001c04 <freeproc>
    release(&np->lock);
    80001e9e:	8552                	mv	a0,s4
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	e4c080e7          	jalr	-436(ra) # 80000cec <release>
    return -1;
    80001ea8:	597d                	li	s2,-1
    80001eaa:	6a42                	ld	s4,16(sp)
    80001eac:	a071                	j	80001f38 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001eae:	04a1                	addi	s1,s1,8
    80001eb0:	0921                	addi	s2,s2,8
    80001eb2:	01348b63          	beq	s1,s3,80001ec8 <fork+0xc0>
    if(p->ofile[i])
    80001eb6:	6088                	ld	a0,0(s1)
    80001eb8:	d97d                	beqz	a0,80001eae <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eba:	00002097          	auipc	ra,0x2
    80001ebe:	742080e7          	jalr	1858(ra) # 800045fc <filedup>
    80001ec2:	00a93023          	sd	a0,0(s2)
    80001ec6:	b7e5                	j	80001eae <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ec8:	150ab503          	ld	a0,336(s5)
    80001ecc:	00002097          	auipc	ra,0x2
    80001ed0:	8ac080e7          	jalr	-1876(ra) # 80003778 <idup>
    80001ed4:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed8:	4641                	li	a2,16
    80001eda:	158a8593          	addi	a1,s5,344
    80001ede:	158a0513          	addi	a0,s4,344
    80001ee2:	fffff097          	auipc	ra,0xfffff
    80001ee6:	f94080e7          	jalr	-108(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001eea:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001eee:	8552                	mv	a0,s4
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	dfc080e7          	jalr	-516(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001ef8:	00011497          	auipc	s1,0x11
    80001efc:	78048493          	addi	s1,s1,1920 # 80013678 <wait_lock>
    80001f00:	8526                	mv	a0,s1
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	d36080e7          	jalr	-714(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f0a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	ddc080e7          	jalr	-548(ra) # 80000cec <release>
  acquire(&np->lock);
    80001f18:	8552                	mv	a0,s4
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	d1e080e7          	jalr	-738(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001f22:	478d                	li	a5,3
    80001f24:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f28:	8552                	mv	a0,s4
    80001f2a:	fffff097          	auipc	ra,0xfffff
    80001f2e:	dc2080e7          	jalr	-574(ra) # 80000cec <release>
  return pid;
    80001f32:	74a2                	ld	s1,40(sp)
    80001f34:	69e2                	ld	s3,24(sp)
    80001f36:	6a42                	ld	s4,16(sp)
}
    80001f38:	854a                	mv	a0,s2
    80001f3a:	70e2                	ld	ra,56(sp)
    80001f3c:	7442                	ld	s0,48(sp)
    80001f3e:	7902                	ld	s2,32(sp)
    80001f40:	6aa2                	ld	s5,8(sp)
    80001f42:	6121                	addi	sp,sp,64
    80001f44:	8082                	ret
    return -1;
    80001f46:	597d                	li	s2,-1
    80001f48:	bfc5                	j	80001f38 <fork+0x130>

0000000080001f4a <scheduler>:
{
    80001f4a:	7139                	addi	sp,sp,-64
    80001f4c:	fc06                	sd	ra,56(sp)
    80001f4e:	f822                	sd	s0,48(sp)
    80001f50:	f426                	sd	s1,40(sp)
    80001f52:	f04a                	sd	s2,32(sp)
    80001f54:	ec4e                	sd	s3,24(sp)
    80001f56:	e852                	sd	s4,16(sp)
    80001f58:	e456                	sd	s5,8(sp)
    80001f5a:	e05a                	sd	s6,0(sp)
    80001f5c:	0080                	addi	s0,sp,64
    80001f5e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f60:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f62:	00779a93          	slli	s5,a5,0x7
    80001f66:	00011717          	auipc	a4,0x11
    80001f6a:	6fa70713          	addi	a4,a4,1786 # 80013660 <pid_lock>
    80001f6e:	9756                	add	a4,a4,s5
    80001f70:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f74:	00011717          	auipc	a4,0x11
    80001f78:	72470713          	addi	a4,a4,1828 # 80013698 <cpus+0x8>
    80001f7c:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f7e:	498d                	li	s3,3
        p->state = RUNNING;
    80001f80:	4b11                	li	s6,4
        c->proc = p;
    80001f82:	079e                	slli	a5,a5,0x7
    80001f84:	00011a17          	auipc	s4,0x11
    80001f88:	6dca0a13          	addi	s4,s4,1756 # 80013660 <pid_lock>
    80001f8c:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f8e:	00017917          	auipc	s2,0x17
    80001f92:	50290913          	addi	s2,s2,1282 # 80019490 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f9a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f9e:	10079073          	csrw	sstatus,a5
    80001fa2:	00012497          	auipc	s1,0x12
    80001fa6:	aee48493          	addi	s1,s1,-1298 # 80013a90 <proc>
    80001faa:	a811                	j	80001fbe <scheduler+0x74>
      release(&p->lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	fffff097          	auipc	ra,0xfffff
    80001fb2:	d3e080e7          	jalr	-706(ra) # 80000cec <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb6:	16848493          	addi	s1,s1,360
    80001fba:	fd248ee3          	beq	s1,s2,80001f96 <scheduler+0x4c>
      acquire(&p->lock);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	c78080e7          	jalr	-904(ra) # 80000c38 <acquire>
      if(p->state == RUNNABLE) {
    80001fc8:	4c9c                	lw	a5,24(s1)
    80001fca:	ff3791e3          	bne	a5,s3,80001fac <scheduler+0x62>
        p->state = RUNNING;
    80001fce:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fd2:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fd6:	06048593          	addi	a1,s1,96
    80001fda:	8556                	mv	a0,s5
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	684080e7          	jalr	1668(ra) # 80002660 <swtch>
        c->proc = 0;
    80001fe4:	020a3823          	sd	zero,48(s4)
    80001fe8:	b7d1                	j	80001fac <scheduler+0x62>

0000000080001fea <sched>:
{
    80001fea:	7179                	addi	sp,sp,-48
    80001fec:	f406                	sd	ra,40(sp)
    80001fee:	f022                	sd	s0,32(sp)
    80001ff0:	ec26                	sd	s1,24(sp)
    80001ff2:	e84a                	sd	s2,16(sp)
    80001ff4:	e44e                	sd	s3,8(sp)
    80001ff6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ff8:	00000097          	auipc	ra,0x0
    80001ffc:	a5a080e7          	jalr	-1446(ra) # 80001a52 <myproc>
    80002000:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	bbc080e7          	jalr	-1092(ra) # 80000bbe <holding>
    8000200a:	c93d                	beqz	a0,80002080 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000200e:	2781                	sext.w	a5,a5
    80002010:	079e                	slli	a5,a5,0x7
    80002012:	00011717          	auipc	a4,0x11
    80002016:	64e70713          	addi	a4,a4,1614 # 80013660 <pid_lock>
    8000201a:	97ba                	add	a5,a5,a4
    8000201c:	0a87a703          	lw	a4,168(a5)
    80002020:	4785                	li	a5,1
    80002022:	06f71763          	bne	a4,a5,80002090 <sched+0xa6>
  if(p->state == RUNNING)
    80002026:	4c98                	lw	a4,24(s1)
    80002028:	4791                	li	a5,4
    8000202a:	06f70b63          	beq	a4,a5,800020a0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000202e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002032:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002034:	efb5                	bnez	a5,800020b0 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002036:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002038:	00011917          	auipc	s2,0x11
    8000203c:	62890913          	addi	s2,s2,1576 # 80013660 <pid_lock>
    80002040:	2781                	sext.w	a5,a5
    80002042:	079e                	slli	a5,a5,0x7
    80002044:	97ca                	add	a5,a5,s2
    80002046:	0ac7a983          	lw	s3,172(a5)
    8000204a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000204c:	2781                	sext.w	a5,a5
    8000204e:	079e                	slli	a5,a5,0x7
    80002050:	00011597          	auipc	a1,0x11
    80002054:	64858593          	addi	a1,a1,1608 # 80013698 <cpus+0x8>
    80002058:	95be                	add	a1,a1,a5
    8000205a:	06048513          	addi	a0,s1,96
    8000205e:	00000097          	auipc	ra,0x0
    80002062:	602080e7          	jalr	1538(ra) # 80002660 <swtch>
    80002066:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002068:	2781                	sext.w	a5,a5
    8000206a:	079e                	slli	a5,a5,0x7
    8000206c:	993e                	add	s2,s2,a5
    8000206e:	0b392623          	sw	s3,172(s2)
}
    80002072:	70a2                	ld	ra,40(sp)
    80002074:	7402                	ld	s0,32(sp)
    80002076:	64e2                	ld	s1,24(sp)
    80002078:	6942                	ld	s2,16(sp)
    8000207a:	69a2                	ld	s3,8(sp)
    8000207c:	6145                	addi	sp,sp,48
    8000207e:	8082                	ret
    panic("sched p->lock");
    80002080:	00006517          	auipc	a0,0x6
    80002084:	17850513          	addi	a0,a0,376 # 800081f8 <etext+0x1f8>
    80002088:	ffffe097          	auipc	ra,0xffffe
    8000208c:	4d8080e7          	jalr	1240(ra) # 80000560 <panic>
    panic("sched locks");
    80002090:	00006517          	auipc	a0,0x6
    80002094:	17850513          	addi	a0,a0,376 # 80008208 <etext+0x208>
    80002098:	ffffe097          	auipc	ra,0xffffe
    8000209c:	4c8080e7          	jalr	1224(ra) # 80000560 <panic>
    panic("sched running");
    800020a0:	00006517          	auipc	a0,0x6
    800020a4:	17850513          	addi	a0,a0,376 # 80008218 <etext+0x218>
    800020a8:	ffffe097          	auipc	ra,0xffffe
    800020ac:	4b8080e7          	jalr	1208(ra) # 80000560 <panic>
    panic("sched interruptible");
    800020b0:	00006517          	auipc	a0,0x6
    800020b4:	17850513          	addi	a0,a0,376 # 80008228 <etext+0x228>
    800020b8:	ffffe097          	auipc	ra,0xffffe
    800020bc:	4a8080e7          	jalr	1192(ra) # 80000560 <panic>

00000000800020c0 <yield>:
{
    800020c0:	1101                	addi	sp,sp,-32
    800020c2:	ec06                	sd	ra,24(sp)
    800020c4:	e822                	sd	s0,16(sp)
    800020c6:	e426                	sd	s1,8(sp)
    800020c8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020ca:	00000097          	auipc	ra,0x0
    800020ce:	988080e7          	jalr	-1656(ra) # 80001a52 <myproc>
    800020d2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	b64080e7          	jalr	-1180(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    800020dc:	478d                	li	a5,3
    800020de:	cc9c                	sw	a5,24(s1)
  sched();
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	f0a080e7          	jalr	-246(ra) # 80001fea <sched>
  release(&p->lock);
    800020e8:	8526                	mv	a0,s1
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	c02080e7          	jalr	-1022(ra) # 80000cec <release>
}
    800020f2:	60e2                	ld	ra,24(sp)
    800020f4:	6442                	ld	s0,16(sp)
    800020f6:	64a2                	ld	s1,8(sp)
    800020f8:	6105                	addi	sp,sp,32
    800020fa:	8082                	ret

00000000800020fc <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020fc:	7179                	addi	sp,sp,-48
    800020fe:	f406                	sd	ra,40(sp)
    80002100:	f022                	sd	s0,32(sp)
    80002102:	ec26                	sd	s1,24(sp)
    80002104:	e84a                	sd	s2,16(sp)
    80002106:	e44e                	sd	s3,8(sp)
    80002108:	1800                	addi	s0,sp,48
    8000210a:	89aa                	mv	s3,a0
    8000210c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000210e:	00000097          	auipc	ra,0x0
    80002112:	944080e7          	jalr	-1724(ra) # 80001a52 <myproc>
    80002116:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	b20080e7          	jalr	-1248(ra) # 80000c38 <acquire>
  release(lk);
    80002120:	854a                	mv	a0,s2
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	bca080e7          	jalr	-1078(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    8000212a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000212e:	4789                	li	a5,2
    80002130:	cc9c                	sw	a5,24(s1)

  sched();
    80002132:	00000097          	auipc	ra,0x0
    80002136:	eb8080e7          	jalr	-328(ra) # 80001fea <sched>

  // Tidy up.
  p->chan = 0;
    8000213a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	bac080e7          	jalr	-1108(ra) # 80000cec <release>
  acquire(lk);
    80002148:	854a                	mv	a0,s2
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	aee080e7          	jalr	-1298(ra) # 80000c38 <acquire>
}
    80002152:	70a2                	ld	ra,40(sp)
    80002154:	7402                	ld	s0,32(sp)
    80002156:	64e2                	ld	s1,24(sp)
    80002158:	6942                	ld	s2,16(sp)
    8000215a:	69a2                	ld	s3,8(sp)
    8000215c:	6145                	addi	sp,sp,48
    8000215e:	8082                	ret

0000000080002160 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002160:	7139                	addi	sp,sp,-64
    80002162:	fc06                	sd	ra,56(sp)
    80002164:	f822                	sd	s0,48(sp)
    80002166:	f426                	sd	s1,40(sp)
    80002168:	f04a                	sd	s2,32(sp)
    8000216a:	ec4e                	sd	s3,24(sp)
    8000216c:	e852                	sd	s4,16(sp)
    8000216e:	e456                	sd	s5,8(sp)
    80002170:	0080                	addi	s0,sp,64
    80002172:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002174:	00012497          	auipc	s1,0x12
    80002178:	91c48493          	addi	s1,s1,-1764 # 80013a90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000217c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000217e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002180:	00017917          	auipc	s2,0x17
    80002184:	31090913          	addi	s2,s2,784 # 80019490 <tickslock>
    80002188:	a811                	j	8000219c <wakeup+0x3c>
      }
      release(&p->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	b60080e7          	jalr	-1184(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002194:	16848493          	addi	s1,s1,360
    80002198:	03248663          	beq	s1,s2,800021c4 <wakeup+0x64>
    if(p != myproc()){
    8000219c:	00000097          	auipc	ra,0x0
    800021a0:	8b6080e7          	jalr	-1866(ra) # 80001a52 <myproc>
    800021a4:	fea488e3          	beq	s1,a0,80002194 <wakeup+0x34>
      acquire(&p->lock);
    800021a8:	8526                	mv	a0,s1
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	a8e080e7          	jalr	-1394(ra) # 80000c38 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021b2:	4c9c                	lw	a5,24(s1)
    800021b4:	fd379be3          	bne	a5,s3,8000218a <wakeup+0x2a>
    800021b8:	709c                	ld	a5,32(s1)
    800021ba:	fd4798e3          	bne	a5,s4,8000218a <wakeup+0x2a>
        p->state = RUNNABLE;
    800021be:	0154ac23          	sw	s5,24(s1)
    800021c2:	b7e1                	j	8000218a <wakeup+0x2a>
    }
  }
}
    800021c4:	70e2                	ld	ra,56(sp)
    800021c6:	7442                	ld	s0,48(sp)
    800021c8:	74a2                	ld	s1,40(sp)
    800021ca:	7902                	ld	s2,32(sp)
    800021cc:	69e2                	ld	s3,24(sp)
    800021ce:	6a42                	ld	s4,16(sp)
    800021d0:	6aa2                	ld	s5,8(sp)
    800021d2:	6121                	addi	sp,sp,64
    800021d4:	8082                	ret

00000000800021d6 <reparent>:
{
    800021d6:	7179                	addi	sp,sp,-48
    800021d8:	f406                	sd	ra,40(sp)
    800021da:	f022                	sd	s0,32(sp)
    800021dc:	ec26                	sd	s1,24(sp)
    800021de:	e84a                	sd	s2,16(sp)
    800021e0:	e44e                	sd	s3,8(sp)
    800021e2:	e052                	sd	s4,0(sp)
    800021e4:	1800                	addi	s0,sp,48
    800021e6:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e8:	00012497          	auipc	s1,0x12
    800021ec:	8a848493          	addi	s1,s1,-1880 # 80013a90 <proc>
      pp->parent = initproc;
    800021f0:	00009a17          	auipc	s4,0x9
    800021f4:	1f8a0a13          	addi	s4,s4,504 # 8000b3e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f8:	00017997          	auipc	s3,0x17
    800021fc:	29898993          	addi	s3,s3,664 # 80019490 <tickslock>
    80002200:	a029                	j	8000220a <reparent+0x34>
    80002202:	16848493          	addi	s1,s1,360
    80002206:	01348d63          	beq	s1,s3,80002220 <reparent+0x4a>
    if(pp->parent == p){
    8000220a:	7c9c                	ld	a5,56(s1)
    8000220c:	ff279be3          	bne	a5,s2,80002202 <reparent+0x2c>
      pp->parent = initproc;
    80002210:	000a3503          	ld	a0,0(s4)
    80002214:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002216:	00000097          	auipc	ra,0x0
    8000221a:	f4a080e7          	jalr	-182(ra) # 80002160 <wakeup>
    8000221e:	b7d5                	j	80002202 <reparent+0x2c>
}
    80002220:	70a2                	ld	ra,40(sp)
    80002222:	7402                	ld	s0,32(sp)
    80002224:	64e2                	ld	s1,24(sp)
    80002226:	6942                	ld	s2,16(sp)
    80002228:	69a2                	ld	s3,8(sp)
    8000222a:	6a02                	ld	s4,0(sp)
    8000222c:	6145                	addi	sp,sp,48
    8000222e:	8082                	ret

0000000080002230 <exit>:
{
    80002230:	7179                	addi	sp,sp,-48
    80002232:	f406                	sd	ra,40(sp)
    80002234:	f022                	sd	s0,32(sp)
    80002236:	ec26                	sd	s1,24(sp)
    80002238:	e84a                	sd	s2,16(sp)
    8000223a:	e44e                	sd	s3,8(sp)
    8000223c:	e052                	sd	s4,0(sp)
    8000223e:	1800                	addi	s0,sp,48
    80002240:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002242:	00000097          	auipc	ra,0x0
    80002246:	810080e7          	jalr	-2032(ra) # 80001a52 <myproc>
    8000224a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000224c:	00009797          	auipc	a5,0x9
    80002250:	19c7b783          	ld	a5,412(a5) # 8000b3e8 <initproc>
    80002254:	0d050493          	addi	s1,a0,208
    80002258:	15050913          	addi	s2,a0,336
    8000225c:	02a79363          	bne	a5,a0,80002282 <exit+0x52>
    panic("init exiting");
    80002260:	00006517          	auipc	a0,0x6
    80002264:	fe050513          	addi	a0,a0,-32 # 80008240 <etext+0x240>
    80002268:	ffffe097          	auipc	ra,0xffffe
    8000226c:	2f8080e7          	jalr	760(ra) # 80000560 <panic>
      fileclose(f);
    80002270:	00002097          	auipc	ra,0x2
    80002274:	3de080e7          	jalr	990(ra) # 8000464e <fileclose>
      p->ofile[fd] = 0;
    80002278:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000227c:	04a1                	addi	s1,s1,8
    8000227e:	01248563          	beq	s1,s2,80002288 <exit+0x58>
    if(p->ofile[fd]){
    80002282:	6088                	ld	a0,0(s1)
    80002284:	f575                	bnez	a0,80002270 <exit+0x40>
    80002286:	bfdd                	j	8000227c <exit+0x4c>
  begin_op();
    80002288:	00002097          	auipc	ra,0x2
    8000228c:	efc080e7          	jalr	-260(ra) # 80004184 <begin_op>
  iput(p->cwd);
    80002290:	1509b503          	ld	a0,336(s3)
    80002294:	00001097          	auipc	ra,0x1
    80002298:	6e0080e7          	jalr	1760(ra) # 80003974 <iput>
  end_op();
    8000229c:	00002097          	auipc	ra,0x2
    800022a0:	f62080e7          	jalr	-158(ra) # 800041fe <end_op>
  p->cwd = 0;
    800022a4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022a8:	00011497          	auipc	s1,0x11
    800022ac:	3d048493          	addi	s1,s1,976 # 80013678 <wait_lock>
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	986080e7          	jalr	-1658(ra) # 80000c38 <acquire>
  reparent(p);
    800022ba:	854e                	mv	a0,s3
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	f1a080e7          	jalr	-230(ra) # 800021d6 <reparent>
  wakeup(p->parent);
    800022c4:	0389b503          	ld	a0,56(s3)
    800022c8:	00000097          	auipc	ra,0x0
    800022cc:	e98080e7          	jalr	-360(ra) # 80002160 <wakeup>
  acquire(&p->lock);
    800022d0:	854e                	mv	a0,s3
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	966080e7          	jalr	-1690(ra) # 80000c38 <acquire>
  p->xstate = status;
    800022da:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022de:	4795                	li	a5,5
    800022e0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022e4:	8526                	mv	a0,s1
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	a06080e7          	jalr	-1530(ra) # 80000cec <release>
  sched();
    800022ee:	00000097          	auipc	ra,0x0
    800022f2:	cfc080e7          	jalr	-772(ra) # 80001fea <sched>
  panic("zombie exit");
    800022f6:	00006517          	auipc	a0,0x6
    800022fa:	f5a50513          	addi	a0,a0,-166 # 80008250 <etext+0x250>
    800022fe:	ffffe097          	auipc	ra,0xffffe
    80002302:	262080e7          	jalr	610(ra) # 80000560 <panic>

0000000080002306 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002306:	7179                	addi	sp,sp,-48
    80002308:	f406                	sd	ra,40(sp)
    8000230a:	f022                	sd	s0,32(sp)
    8000230c:	ec26                	sd	s1,24(sp)
    8000230e:	e84a                	sd	s2,16(sp)
    80002310:	e44e                	sd	s3,8(sp)
    80002312:	1800                	addi	s0,sp,48
    80002314:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002316:	00011497          	auipc	s1,0x11
    8000231a:	77a48493          	addi	s1,s1,1914 # 80013a90 <proc>
    8000231e:	00017997          	auipc	s3,0x17
    80002322:	17298993          	addi	s3,s3,370 # 80019490 <tickslock>
    acquire(&p->lock);
    80002326:	8526                	mv	a0,s1
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	910080e7          	jalr	-1776(ra) # 80000c38 <acquire>
    if(p->pid == pid){
    80002330:	589c                	lw	a5,48(s1)
    80002332:	01278d63          	beq	a5,s2,8000234c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002336:	8526                	mv	a0,s1
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	9b4080e7          	jalr	-1612(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002340:	16848493          	addi	s1,s1,360
    80002344:	ff3491e3          	bne	s1,s3,80002326 <kill+0x20>
  }
  return -1;
    80002348:	557d                	li	a0,-1
    8000234a:	a829                	j	80002364 <kill+0x5e>
      p->killed = 1;
    8000234c:	4785                	li	a5,1
    8000234e:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002350:	4c98                	lw	a4,24(s1)
    80002352:	4789                	li	a5,2
    80002354:	00f70f63          	beq	a4,a5,80002372 <kill+0x6c>
      release(&p->lock);
    80002358:	8526                	mv	a0,s1
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	992080e7          	jalr	-1646(ra) # 80000cec <release>
      return 0;
    80002362:	4501                	li	a0,0
}
    80002364:	70a2                	ld	ra,40(sp)
    80002366:	7402                	ld	s0,32(sp)
    80002368:	64e2                	ld	s1,24(sp)
    8000236a:	6942                	ld	s2,16(sp)
    8000236c:	69a2                	ld	s3,8(sp)
    8000236e:	6145                	addi	sp,sp,48
    80002370:	8082                	ret
        p->state = RUNNABLE;
    80002372:	478d                	li	a5,3
    80002374:	cc9c                	sw	a5,24(s1)
    80002376:	b7cd                	j	80002358 <kill+0x52>

0000000080002378 <setkilled>:

void
setkilled(struct proc *p)
{
    80002378:	1101                	addi	sp,sp,-32
    8000237a:	ec06                	sd	ra,24(sp)
    8000237c:	e822                	sd	s0,16(sp)
    8000237e:	e426                	sd	s1,8(sp)
    80002380:	1000                	addi	s0,sp,32
    80002382:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	8b4080e7          	jalr	-1868(ra) # 80000c38 <acquire>
  p->killed = 1;
    8000238c:	4785                	li	a5,1
    8000238e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002390:	8526                	mv	a0,s1
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	95a080e7          	jalr	-1702(ra) # 80000cec <release>
}
    8000239a:	60e2                	ld	ra,24(sp)
    8000239c:	6442                	ld	s0,16(sp)
    8000239e:	64a2                	ld	s1,8(sp)
    800023a0:	6105                	addi	sp,sp,32
    800023a2:	8082                	ret

00000000800023a4 <killed>:

int
killed(struct proc *p)
{
    800023a4:	1101                	addi	sp,sp,-32
    800023a6:	ec06                	sd	ra,24(sp)
    800023a8:	e822                	sd	s0,16(sp)
    800023aa:	e426                	sd	s1,8(sp)
    800023ac:	e04a                	sd	s2,0(sp)
    800023ae:	1000                	addi	s0,sp,32
    800023b0:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	886080e7          	jalr	-1914(ra) # 80000c38 <acquire>
  k = p->killed;
    800023ba:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023be:	8526                	mv	a0,s1
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	92c080e7          	jalr	-1748(ra) # 80000cec <release>
  return k;
}
    800023c8:	854a                	mv	a0,s2
    800023ca:	60e2                	ld	ra,24(sp)
    800023cc:	6442                	ld	s0,16(sp)
    800023ce:	64a2                	ld	s1,8(sp)
    800023d0:	6902                	ld	s2,0(sp)
    800023d2:	6105                	addi	sp,sp,32
    800023d4:	8082                	ret

00000000800023d6 <wait>:
{
    800023d6:	715d                	addi	sp,sp,-80
    800023d8:	e486                	sd	ra,72(sp)
    800023da:	e0a2                	sd	s0,64(sp)
    800023dc:	fc26                	sd	s1,56(sp)
    800023de:	f84a                	sd	s2,48(sp)
    800023e0:	f44e                	sd	s3,40(sp)
    800023e2:	f052                	sd	s4,32(sp)
    800023e4:	ec56                	sd	s5,24(sp)
    800023e6:	e85a                	sd	s6,16(sp)
    800023e8:	e45e                	sd	s7,8(sp)
    800023ea:	e062                	sd	s8,0(sp)
    800023ec:	0880                	addi	s0,sp,80
    800023ee:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	662080e7          	jalr	1634(ra) # 80001a52 <myproc>
    800023f8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023fa:	00011517          	auipc	a0,0x11
    800023fe:	27e50513          	addi	a0,a0,638 # 80013678 <wait_lock>
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	836080e7          	jalr	-1994(ra) # 80000c38 <acquire>
    havekids = 0;
    8000240a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000240c:	4a15                	li	s4,5
        havekids = 1;
    8000240e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002410:	00017997          	auipc	s3,0x17
    80002414:	08098993          	addi	s3,s3,128 # 80019490 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002418:	00011c17          	auipc	s8,0x11
    8000241c:	260c0c13          	addi	s8,s8,608 # 80013678 <wait_lock>
    80002420:	a0d1                	j	800024e4 <wait+0x10e>
          pid = pp->pid;
    80002422:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002426:	000b0e63          	beqz	s6,80002442 <wait+0x6c>
    8000242a:	4691                	li	a3,4
    8000242c:	02c48613          	addi	a2,s1,44
    80002430:	85da                	mv	a1,s6
    80002432:	05093503          	ld	a0,80(s2)
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	2b4080e7          	jalr	692(ra) # 800016ea <copyout>
    8000243e:	04054163          	bltz	a0,80002480 <wait+0xaa>
          freeproc(pp);
    80002442:	8526                	mv	a0,s1
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	7c0080e7          	jalr	1984(ra) # 80001c04 <freeproc>
          release(&pp->lock);
    8000244c:	8526                	mv	a0,s1
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	89e080e7          	jalr	-1890(ra) # 80000cec <release>
          release(&wait_lock);
    80002456:	00011517          	auipc	a0,0x11
    8000245a:	22250513          	addi	a0,a0,546 # 80013678 <wait_lock>
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	88e080e7          	jalr	-1906(ra) # 80000cec <release>
}
    80002466:	854e                	mv	a0,s3
    80002468:	60a6                	ld	ra,72(sp)
    8000246a:	6406                	ld	s0,64(sp)
    8000246c:	74e2                	ld	s1,56(sp)
    8000246e:	7942                	ld	s2,48(sp)
    80002470:	79a2                	ld	s3,40(sp)
    80002472:	7a02                	ld	s4,32(sp)
    80002474:	6ae2                	ld	s5,24(sp)
    80002476:	6b42                	ld	s6,16(sp)
    80002478:	6ba2                	ld	s7,8(sp)
    8000247a:	6c02                	ld	s8,0(sp)
    8000247c:	6161                	addi	sp,sp,80
    8000247e:	8082                	ret
            release(&pp->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	86a080e7          	jalr	-1942(ra) # 80000cec <release>
            release(&wait_lock);
    8000248a:	00011517          	auipc	a0,0x11
    8000248e:	1ee50513          	addi	a0,a0,494 # 80013678 <wait_lock>
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	85a080e7          	jalr	-1958(ra) # 80000cec <release>
            return -1;
    8000249a:	59fd                	li	s3,-1
    8000249c:	b7e9                	j	80002466 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000249e:	16848493          	addi	s1,s1,360
    800024a2:	03348463          	beq	s1,s3,800024ca <wait+0xf4>
      if(pp->parent == p){
    800024a6:	7c9c                	ld	a5,56(s1)
    800024a8:	ff279be3          	bne	a5,s2,8000249e <wait+0xc8>
        acquire(&pp->lock);
    800024ac:	8526                	mv	a0,s1
    800024ae:	ffffe097          	auipc	ra,0xffffe
    800024b2:	78a080e7          	jalr	1930(ra) # 80000c38 <acquire>
        if(pp->state == ZOMBIE){
    800024b6:	4c9c                	lw	a5,24(s1)
    800024b8:	f74785e3          	beq	a5,s4,80002422 <wait+0x4c>
        release(&pp->lock);
    800024bc:	8526                	mv	a0,s1
    800024be:	fffff097          	auipc	ra,0xfffff
    800024c2:	82e080e7          	jalr	-2002(ra) # 80000cec <release>
        havekids = 1;
    800024c6:	8756                	mv	a4,s5
    800024c8:	bfd9                	j	8000249e <wait+0xc8>
    if(!havekids || killed(p)){
    800024ca:	c31d                	beqz	a4,800024f0 <wait+0x11a>
    800024cc:	854a                	mv	a0,s2
    800024ce:	00000097          	auipc	ra,0x0
    800024d2:	ed6080e7          	jalr	-298(ra) # 800023a4 <killed>
    800024d6:	ed09                	bnez	a0,800024f0 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024d8:	85e2                	mv	a1,s8
    800024da:	854a                	mv	a0,s2
    800024dc:	00000097          	auipc	ra,0x0
    800024e0:	c20080e7          	jalr	-992(ra) # 800020fc <sleep>
    havekids = 0;
    800024e4:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024e6:	00011497          	auipc	s1,0x11
    800024ea:	5aa48493          	addi	s1,s1,1450 # 80013a90 <proc>
    800024ee:	bf65                	j	800024a6 <wait+0xd0>
      release(&wait_lock);
    800024f0:	00011517          	auipc	a0,0x11
    800024f4:	18850513          	addi	a0,a0,392 # 80013678 <wait_lock>
    800024f8:	ffffe097          	auipc	ra,0xffffe
    800024fc:	7f4080e7          	jalr	2036(ra) # 80000cec <release>
      return -1;
    80002500:	59fd                	li	s3,-1
    80002502:	b795                	j	80002466 <wait+0x90>

0000000080002504 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002504:	7179                	addi	sp,sp,-48
    80002506:	f406                	sd	ra,40(sp)
    80002508:	f022                	sd	s0,32(sp)
    8000250a:	ec26                	sd	s1,24(sp)
    8000250c:	e84a                	sd	s2,16(sp)
    8000250e:	e44e                	sd	s3,8(sp)
    80002510:	e052                	sd	s4,0(sp)
    80002512:	1800                	addi	s0,sp,48
    80002514:	84aa                	mv	s1,a0
    80002516:	892e                	mv	s2,a1
    80002518:	89b2                	mv	s3,a2
    8000251a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	536080e7          	jalr	1334(ra) # 80001a52 <myproc>
  if(user_dst){
    80002524:	c08d                	beqz	s1,80002546 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002526:	86d2                	mv	a3,s4
    80002528:	864e                	mv	a2,s3
    8000252a:	85ca                	mv	a1,s2
    8000252c:	6928                	ld	a0,80(a0)
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	1bc080e7          	jalr	444(ra) # 800016ea <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002536:	70a2                	ld	ra,40(sp)
    80002538:	7402                	ld	s0,32(sp)
    8000253a:	64e2                	ld	s1,24(sp)
    8000253c:	6942                	ld	s2,16(sp)
    8000253e:	69a2                	ld	s3,8(sp)
    80002540:	6a02                	ld	s4,0(sp)
    80002542:	6145                	addi	sp,sp,48
    80002544:	8082                	ret
    memmove((char *)dst, src, len);
    80002546:	000a061b          	sext.w	a2,s4
    8000254a:	85ce                	mv	a1,s3
    8000254c:	854a                	mv	a0,s2
    8000254e:	fffff097          	auipc	ra,0xfffff
    80002552:	842080e7          	jalr	-1982(ra) # 80000d90 <memmove>
    return 0;
    80002556:	8526                	mv	a0,s1
    80002558:	bff9                	j	80002536 <either_copyout+0x32>

000000008000255a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000255a:	7179                	addi	sp,sp,-48
    8000255c:	f406                	sd	ra,40(sp)
    8000255e:	f022                	sd	s0,32(sp)
    80002560:	ec26                	sd	s1,24(sp)
    80002562:	e84a                	sd	s2,16(sp)
    80002564:	e44e                	sd	s3,8(sp)
    80002566:	e052                	sd	s4,0(sp)
    80002568:	1800                	addi	s0,sp,48
    8000256a:	892a                	mv	s2,a0
    8000256c:	84ae                	mv	s1,a1
    8000256e:	89b2                	mv	s3,a2
    80002570:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002572:	fffff097          	auipc	ra,0xfffff
    80002576:	4e0080e7          	jalr	1248(ra) # 80001a52 <myproc>
  if(user_src){
    8000257a:	c08d                	beqz	s1,8000259c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000257c:	86d2                	mv	a3,s4
    8000257e:	864e                	mv	a2,s3
    80002580:	85ca                	mv	a1,s2
    80002582:	6928                	ld	a0,80(a0)
    80002584:	fffff097          	auipc	ra,0xfffff
    80002588:	1f2080e7          	jalr	498(ra) # 80001776 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000258c:	70a2                	ld	ra,40(sp)
    8000258e:	7402                	ld	s0,32(sp)
    80002590:	64e2                	ld	s1,24(sp)
    80002592:	6942                	ld	s2,16(sp)
    80002594:	69a2                	ld	s3,8(sp)
    80002596:	6a02                	ld	s4,0(sp)
    80002598:	6145                	addi	sp,sp,48
    8000259a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000259c:	000a061b          	sext.w	a2,s4
    800025a0:	85ce                	mv	a1,s3
    800025a2:	854a                	mv	a0,s2
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	7ec080e7          	jalr	2028(ra) # 80000d90 <memmove>
    return 0;
    800025ac:	8526                	mv	a0,s1
    800025ae:	bff9                	j	8000258c <either_copyin+0x32>

00000000800025b0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025b0:	715d                	addi	sp,sp,-80
    800025b2:	e486                	sd	ra,72(sp)
    800025b4:	e0a2                	sd	s0,64(sp)
    800025b6:	fc26                	sd	s1,56(sp)
    800025b8:	f84a                	sd	s2,48(sp)
    800025ba:	f44e                	sd	s3,40(sp)
    800025bc:	f052                	sd	s4,32(sp)
    800025be:	ec56                	sd	s5,24(sp)
    800025c0:	e85a                	sd	s6,16(sp)
    800025c2:	e45e                	sd	s7,8(sp)
    800025c4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025c6:	00006517          	auipc	a0,0x6
    800025ca:	a4a50513          	addi	a0,a0,-1462 # 80008010 <etext+0x10>
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	fdc080e7          	jalr	-36(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025d6:	00011497          	auipc	s1,0x11
    800025da:	61248493          	addi	s1,s1,1554 # 80013be8 <proc+0x158>
    800025de:	00017917          	auipc	s2,0x17
    800025e2:	00a90913          	addi	s2,s2,10 # 800195e8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e6:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025e8:	00006997          	auipc	s3,0x6
    800025ec:	c7898993          	addi	s3,s3,-904 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    800025f0:	00006a97          	auipc	s5,0x6
    800025f4:	c78a8a93          	addi	s5,s5,-904 # 80008268 <etext+0x268>
    printf("\n");
    800025f8:	00006a17          	auipc	s4,0x6
    800025fc:	a18a0a13          	addi	s4,s4,-1512 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002600:	00006b97          	auipc	s7,0x6
    80002604:	1b0b8b93          	addi	s7,s7,432 # 800087b0 <states.0>
    80002608:	a00d                	j	8000262a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000260a:	ed86a583          	lw	a1,-296(a3)
    8000260e:	8556                	mv	a0,s5
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	f9a080e7          	jalr	-102(ra) # 800005aa <printf>
    printf("\n");
    80002618:	8552                	mv	a0,s4
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	f90080e7          	jalr	-112(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002622:	16848493          	addi	s1,s1,360
    80002626:	03248263          	beq	s1,s2,8000264a <procdump+0x9a>
    if(p->state == UNUSED)
    8000262a:	86a6                	mv	a3,s1
    8000262c:	ec04a783          	lw	a5,-320(s1)
    80002630:	dbed                	beqz	a5,80002622 <procdump+0x72>
      state = "???";
    80002632:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002634:	fcfb6be3          	bltu	s6,a5,8000260a <procdump+0x5a>
    80002638:	02079713          	slli	a4,a5,0x20
    8000263c:	01d75793          	srli	a5,a4,0x1d
    80002640:	97de                	add	a5,a5,s7
    80002642:	6390                	ld	a2,0(a5)
    80002644:	f279                	bnez	a2,8000260a <procdump+0x5a>
      state = "???";
    80002646:	864e                	mv	a2,s3
    80002648:	b7c9                	j	8000260a <procdump+0x5a>
  }
}
    8000264a:	60a6                	ld	ra,72(sp)
    8000264c:	6406                	ld	s0,64(sp)
    8000264e:	74e2                	ld	s1,56(sp)
    80002650:	7942                	ld	s2,48(sp)
    80002652:	79a2                	ld	s3,40(sp)
    80002654:	7a02                	ld	s4,32(sp)
    80002656:	6ae2                	ld	s5,24(sp)
    80002658:	6b42                	ld	s6,16(sp)
    8000265a:	6ba2                	ld	s7,8(sp)
    8000265c:	6161                	addi	sp,sp,80
    8000265e:	8082                	ret

0000000080002660 <swtch>:
    80002660:	00153023          	sd	ra,0(a0)
    80002664:	00253423          	sd	sp,8(a0)
    80002668:	e900                	sd	s0,16(a0)
    8000266a:	ed04                	sd	s1,24(a0)
    8000266c:	03253023          	sd	s2,32(a0)
    80002670:	03353423          	sd	s3,40(a0)
    80002674:	03453823          	sd	s4,48(a0)
    80002678:	03553c23          	sd	s5,56(a0)
    8000267c:	05653023          	sd	s6,64(a0)
    80002680:	05753423          	sd	s7,72(a0)
    80002684:	05853823          	sd	s8,80(a0)
    80002688:	05953c23          	sd	s9,88(a0)
    8000268c:	07a53023          	sd	s10,96(a0)
    80002690:	07b53423          	sd	s11,104(a0)
    80002694:	0005b083          	ld	ra,0(a1)
    80002698:	0085b103          	ld	sp,8(a1)
    8000269c:	6980                	ld	s0,16(a1)
    8000269e:	6d84                	ld	s1,24(a1)
    800026a0:	0205b903          	ld	s2,32(a1)
    800026a4:	0285b983          	ld	s3,40(a1)
    800026a8:	0305ba03          	ld	s4,48(a1)
    800026ac:	0385ba83          	ld	s5,56(a1)
    800026b0:	0405bb03          	ld	s6,64(a1)
    800026b4:	0485bb83          	ld	s7,72(a1)
    800026b8:	0505bc03          	ld	s8,80(a1)
    800026bc:	0585bc83          	ld	s9,88(a1)
    800026c0:	0605bd03          	ld	s10,96(a1)
    800026c4:	0685bd83          	ld	s11,104(a1)
    800026c8:	8082                	ret

00000000800026ca <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026ca:	1141                	addi	sp,sp,-16
    800026cc:	e406                	sd	ra,8(sp)
    800026ce:	e022                	sd	s0,0(sp)
    800026d0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026d2:	00006597          	auipc	a1,0x6
    800026d6:	bd658593          	addi	a1,a1,-1066 # 800082a8 <etext+0x2a8>
    800026da:	00017517          	auipc	a0,0x17
    800026de:	db650513          	addi	a0,a0,-586 # 80019490 <tickslock>
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	4c6080e7          	jalr	1222(ra) # 80000ba8 <initlock>
}
    800026ea:	60a2                	ld	ra,8(sp)
    800026ec:	6402                	ld	s0,0(sp)
    800026ee:	0141                	addi	sp,sp,16
    800026f0:	8082                	ret

00000000800026f2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026f2:	1141                	addi	sp,sp,-16
    800026f4:	e422                	sd	s0,8(sp)
    800026f6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026f8:	00003797          	auipc	a5,0x3
    800026fc:	65878793          	addi	a5,a5,1624 # 80005d50 <kernelvec>
    80002700:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002704:	6422                	ld	s0,8(sp)
    80002706:	0141                	addi	sp,sp,16
    80002708:	8082                	ret

000000008000270a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000270a:	1141                	addi	sp,sp,-16
    8000270c:	e406                	sd	ra,8(sp)
    8000270e:	e022                	sd	s0,0(sp)
    80002710:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002712:	fffff097          	auipc	ra,0xfffff
    80002716:	340080e7          	jalr	832(ra) # 80001a52 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000271a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000271e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002720:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002724:	00005697          	auipc	a3,0x5
    80002728:	8dc68693          	addi	a3,a3,-1828 # 80007000 <_trampoline>
    8000272c:	00005717          	auipc	a4,0x5
    80002730:	8d470713          	addi	a4,a4,-1836 # 80007000 <_trampoline>
    80002734:	8f15                	sub	a4,a4,a3
    80002736:	040007b7          	lui	a5,0x4000
    8000273a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000273c:	07b2                	slli	a5,a5,0xc
    8000273e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002740:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002744:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002746:	18002673          	csrr	a2,satp
    8000274a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000274c:	6d30                	ld	a2,88(a0)
    8000274e:	6138                	ld	a4,64(a0)
    80002750:	6585                	lui	a1,0x1
    80002752:	972e                	add	a4,a4,a1
    80002754:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002756:	6d38                	ld	a4,88(a0)
    80002758:	00000617          	auipc	a2,0x0
    8000275c:	13860613          	addi	a2,a2,312 # 80002890 <usertrap>
    80002760:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002762:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002764:	8612                	mv	a2,tp
    80002766:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002768:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000276c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002770:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002774:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002778:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000277a:	6f18                	ld	a4,24(a4)
    8000277c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002780:	6928                	ld	a0,80(a0)
    80002782:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002784:	00005717          	auipc	a4,0x5
    80002788:	91870713          	addi	a4,a4,-1768 # 8000709c <userret>
    8000278c:	8f15                	sub	a4,a4,a3
    8000278e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002790:	577d                	li	a4,-1
    80002792:	177e                	slli	a4,a4,0x3f
    80002794:	8d59                	or	a0,a0,a4
    80002796:	9782                	jalr	a5
}
    80002798:	60a2                	ld	ra,8(sp)
    8000279a:	6402                	ld	s0,0(sp)
    8000279c:	0141                	addi	sp,sp,16
    8000279e:	8082                	ret

00000000800027a0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027a0:	1101                	addi	sp,sp,-32
    800027a2:	ec06                	sd	ra,24(sp)
    800027a4:	e822                	sd	s0,16(sp)
    800027a6:	e426                	sd	s1,8(sp)
    800027a8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027aa:	00017497          	auipc	s1,0x17
    800027ae:	ce648493          	addi	s1,s1,-794 # 80019490 <tickslock>
    800027b2:	8526                	mv	a0,s1
    800027b4:	ffffe097          	auipc	ra,0xffffe
    800027b8:	484080e7          	jalr	1156(ra) # 80000c38 <acquire>
  ticks++;
    800027bc:	00009517          	auipc	a0,0x9
    800027c0:	c3450513          	addi	a0,a0,-972 # 8000b3f0 <ticks>
    800027c4:	411c                	lw	a5,0(a0)
    800027c6:	2785                	addiw	a5,a5,1
    800027c8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027ca:	00000097          	auipc	ra,0x0
    800027ce:	996080e7          	jalr	-1642(ra) # 80002160 <wakeup>
  release(&tickslock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	518080e7          	jalr	1304(ra) # 80000cec <release>
}
    800027dc:	60e2                	ld	ra,24(sp)
    800027de:	6442                	ld	s0,16(sp)
    800027e0:	64a2                	ld	s1,8(sp)
    800027e2:	6105                	addi	sp,sp,32
    800027e4:	8082                	ret

00000000800027e6 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027e6:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027ea:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800027ec:	0a07d163          	bgez	a5,8000288e <devintr+0xa8>
{
    800027f0:	1101                	addi	sp,sp,-32
    800027f2:	ec06                	sd	ra,24(sp)
    800027f4:	e822                	sd	s0,16(sp)
    800027f6:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    800027f8:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800027fc:	46a5                	li	a3,9
    800027fe:	00d70c63          	beq	a4,a3,80002816 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002802:	577d                	li	a4,-1
    80002804:	177e                	slli	a4,a4,0x3f
    80002806:	0705                	addi	a4,a4,1
    return 0;
    80002808:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000280a:	06e78163          	beq	a5,a4,8000286c <devintr+0x86>
  }
}
    8000280e:	60e2                	ld	ra,24(sp)
    80002810:	6442                	ld	s0,16(sp)
    80002812:	6105                	addi	sp,sp,32
    80002814:	8082                	ret
    80002816:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002818:	00004097          	auipc	ra,0x4
    8000281c:	8aa080e7          	jalr	-1878(ra) # 800060c2 <plic_claim>
    80002820:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002822:	47a9                	li	a5,10
    80002824:	00f50963          	beq	a0,a5,80002836 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002828:	4785                	li	a5,1
    8000282a:	00f50b63          	beq	a0,a5,80002840 <devintr+0x5a>
    return 1;
    8000282e:	4505                	li	a0,1
    } else if(irq){
    80002830:	ec89                	bnez	s1,8000284a <devintr+0x64>
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	bfe9                	j	8000280e <devintr+0x28>
      uartintr();
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	1c4080e7          	jalr	452(ra) # 800009fa <uartintr>
    if(irq)
    8000283e:	a839                	j	8000285c <devintr+0x76>
      virtio_disk_intr();
    80002840:	00004097          	auipc	ra,0x4
    80002844:	dac080e7          	jalr	-596(ra) # 800065ec <virtio_disk_intr>
    if(irq)
    80002848:	a811                	j	8000285c <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    8000284a:	85a6                	mv	a1,s1
    8000284c:	00006517          	auipc	a0,0x6
    80002850:	a6450513          	addi	a0,a0,-1436 # 800082b0 <etext+0x2b0>
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	d56080e7          	jalr	-682(ra) # 800005aa <printf>
      plic_complete(irq);
    8000285c:	8526                	mv	a0,s1
    8000285e:	00004097          	auipc	ra,0x4
    80002862:	888080e7          	jalr	-1912(ra) # 800060e6 <plic_complete>
    return 1;
    80002866:	4505                	li	a0,1
    80002868:	64a2                	ld	s1,8(sp)
    8000286a:	b755                	j	8000280e <devintr+0x28>
    if(cpuid() == 0){
    8000286c:	fffff097          	auipc	ra,0xfffff
    80002870:	1ba080e7          	jalr	442(ra) # 80001a26 <cpuid>
    80002874:	c901                	beqz	a0,80002884 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002876:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000287a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000287c:	14479073          	csrw	sip,a5
    return 2;
    80002880:	4509                	li	a0,2
    80002882:	b771                	j	8000280e <devintr+0x28>
      clockintr();
    80002884:	00000097          	auipc	ra,0x0
    80002888:	f1c080e7          	jalr	-228(ra) # 800027a0 <clockintr>
    8000288c:	b7ed                	j	80002876 <devintr+0x90>
}
    8000288e:	8082                	ret

0000000080002890 <usertrap>:
{
    80002890:	1101                	addi	sp,sp,-32
    80002892:	ec06                	sd	ra,24(sp)
    80002894:	e822                	sd	s0,16(sp)
    80002896:	e426                	sd	s1,8(sp)
    80002898:	e04a                	sd	s2,0(sp)
    8000289a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000289c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028a0:	1007f793          	andi	a5,a5,256
    800028a4:	e3b1                	bnez	a5,800028e8 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a6:	00003797          	auipc	a5,0x3
    800028aa:	4aa78793          	addi	a5,a5,1194 # 80005d50 <kernelvec>
    800028ae:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028b2:	fffff097          	auipc	ra,0xfffff
    800028b6:	1a0080e7          	jalr	416(ra) # 80001a52 <myproc>
    800028ba:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028bc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028be:	14102773          	csrr	a4,sepc
    800028c2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028c4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028c8:	47a1                	li	a5,8
    800028ca:	02f70763          	beq	a4,a5,800028f8 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    800028ce:	00000097          	auipc	ra,0x0
    800028d2:	f18080e7          	jalr	-232(ra) # 800027e6 <devintr>
    800028d6:	892a                	mv	s2,a0
    800028d8:	c151                	beqz	a0,8000295c <usertrap+0xcc>
  if(killed(p))
    800028da:	8526                	mv	a0,s1
    800028dc:	00000097          	auipc	ra,0x0
    800028e0:	ac8080e7          	jalr	-1336(ra) # 800023a4 <killed>
    800028e4:	c929                	beqz	a0,80002936 <usertrap+0xa6>
    800028e6:	a099                	j	8000292c <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028e8:	00006517          	auipc	a0,0x6
    800028ec:	9e850513          	addi	a0,a0,-1560 # 800082d0 <etext+0x2d0>
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	c70080e7          	jalr	-912(ra) # 80000560 <panic>
    if(killed(p))
    800028f8:	00000097          	auipc	ra,0x0
    800028fc:	aac080e7          	jalr	-1364(ra) # 800023a4 <killed>
    80002900:	e921                	bnez	a0,80002950 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002902:	6cb8                	ld	a4,88(s1)
    80002904:	6f1c                	ld	a5,24(a4)
    80002906:	0791                	addi	a5,a5,4
    80002908:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000290e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002912:	10079073          	csrw	sstatus,a5
    syscall();
    80002916:	00000097          	auipc	ra,0x0
    8000291a:	2d4080e7          	jalr	724(ra) # 80002bea <syscall>
  if(killed(p))
    8000291e:	8526                	mv	a0,s1
    80002920:	00000097          	auipc	ra,0x0
    80002924:	a84080e7          	jalr	-1404(ra) # 800023a4 <killed>
    80002928:	c911                	beqz	a0,8000293c <usertrap+0xac>
    8000292a:	4901                	li	s2,0
    exit(-1);
    8000292c:	557d                	li	a0,-1
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	902080e7          	jalr	-1790(ra) # 80002230 <exit>
  if(which_dev == 2)
    80002936:	4789                	li	a5,2
    80002938:	04f90f63          	beq	s2,a5,80002996 <usertrap+0x106>
  usertrapret();
    8000293c:	00000097          	auipc	ra,0x0
    80002940:	dce080e7          	jalr	-562(ra) # 8000270a <usertrapret>
}
    80002944:	60e2                	ld	ra,24(sp)
    80002946:	6442                	ld	s0,16(sp)
    80002948:	64a2                	ld	s1,8(sp)
    8000294a:	6902                	ld	s2,0(sp)
    8000294c:	6105                	addi	sp,sp,32
    8000294e:	8082                	ret
      exit(-1);
    80002950:	557d                	li	a0,-1
    80002952:	00000097          	auipc	ra,0x0
    80002956:	8de080e7          	jalr	-1826(ra) # 80002230 <exit>
    8000295a:	b765                	j	80002902 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000295c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002960:	5890                	lw	a2,48(s1)
    80002962:	00006517          	auipc	a0,0x6
    80002966:	98e50513          	addi	a0,a0,-1650 # 800082f0 <etext+0x2f0>
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	c40080e7          	jalr	-960(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002972:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002976:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000297a:	00006517          	auipc	a0,0x6
    8000297e:	9a650513          	addi	a0,a0,-1626 # 80008320 <etext+0x320>
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	c28080e7          	jalr	-984(ra) # 800005aa <printf>
    setkilled(p);
    8000298a:	8526                	mv	a0,s1
    8000298c:	00000097          	auipc	ra,0x0
    80002990:	9ec080e7          	jalr	-1556(ra) # 80002378 <setkilled>
    80002994:	b769                	j	8000291e <usertrap+0x8e>
    yield();
    80002996:	fffff097          	auipc	ra,0xfffff
    8000299a:	72a080e7          	jalr	1834(ra) # 800020c0 <yield>
    8000299e:	bf79                	j	8000293c <usertrap+0xac>

00000000800029a0 <kerneltrap>:
{
    800029a0:	7179                	addi	sp,sp,-48
    800029a2:	f406                	sd	ra,40(sp)
    800029a4:	f022                	sd	s0,32(sp)
    800029a6:	ec26                	sd	s1,24(sp)
    800029a8:	e84a                	sd	s2,16(sp)
    800029aa:	e44e                	sd	s3,8(sp)
    800029ac:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ae:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029b6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029ba:	1004f793          	andi	a5,s1,256
    800029be:	cb85                	beqz	a5,800029ee <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029c0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029c4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029c6:	ef85                	bnez	a5,800029fe <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029c8:	00000097          	auipc	ra,0x0
    800029cc:	e1e080e7          	jalr	-482(ra) # 800027e6 <devintr>
    800029d0:	cd1d                	beqz	a0,80002a0e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029d2:	4789                	li	a5,2
    800029d4:	06f50a63          	beq	a0,a5,80002a48 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029d8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029dc:	10049073          	csrw	sstatus,s1
}
    800029e0:	70a2                	ld	ra,40(sp)
    800029e2:	7402                	ld	s0,32(sp)
    800029e4:	64e2                	ld	s1,24(sp)
    800029e6:	6942                	ld	s2,16(sp)
    800029e8:	69a2                	ld	s3,8(sp)
    800029ea:	6145                	addi	sp,sp,48
    800029ec:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029ee:	00006517          	auipc	a0,0x6
    800029f2:	95250513          	addi	a0,a0,-1710 # 80008340 <etext+0x340>
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	b6a080e7          	jalr	-1174(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    800029fe:	00006517          	auipc	a0,0x6
    80002a02:	96a50513          	addi	a0,a0,-1686 # 80008368 <etext+0x368>
    80002a06:	ffffe097          	auipc	ra,0xffffe
    80002a0a:	b5a080e7          	jalr	-1190(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002a0e:	85ce                	mv	a1,s3
    80002a10:	00006517          	auipc	a0,0x6
    80002a14:	97850513          	addi	a0,a0,-1672 # 80008388 <etext+0x388>
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	b92080e7          	jalr	-1134(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a20:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a24:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a28:	00006517          	auipc	a0,0x6
    80002a2c:	97050513          	addi	a0,a0,-1680 # 80008398 <etext+0x398>
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	b7a080e7          	jalr	-1158(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002a38:	00006517          	auipc	a0,0x6
    80002a3c:	97850513          	addi	a0,a0,-1672 # 800083b0 <etext+0x3b0>
    80002a40:	ffffe097          	auipc	ra,0xffffe
    80002a44:	b20080e7          	jalr	-1248(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a48:	fffff097          	auipc	ra,0xfffff
    80002a4c:	00a080e7          	jalr	10(ra) # 80001a52 <myproc>
    80002a50:	d541                	beqz	a0,800029d8 <kerneltrap+0x38>
    80002a52:	fffff097          	auipc	ra,0xfffff
    80002a56:	000080e7          	jalr	ra # 80001a52 <myproc>
    80002a5a:	4d18                	lw	a4,24(a0)
    80002a5c:	4791                	li	a5,4
    80002a5e:	f6f71de3          	bne	a4,a5,800029d8 <kerneltrap+0x38>
    yield();
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	65e080e7          	jalr	1630(ra) # 800020c0 <yield>
    80002a6a:	b7bd                	j	800029d8 <kerneltrap+0x38>

0000000080002a6c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a6c:	1101                	addi	sp,sp,-32
    80002a6e:	ec06                	sd	ra,24(sp)
    80002a70:	e822                	sd	s0,16(sp)
    80002a72:	e426                	sd	s1,8(sp)
    80002a74:	1000                	addi	s0,sp,32
    80002a76:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a78:	fffff097          	auipc	ra,0xfffff
    80002a7c:	fda080e7          	jalr	-38(ra) # 80001a52 <myproc>
  switch (n) {
    80002a80:	4795                	li	a5,5
    80002a82:	0497e163          	bltu	a5,s1,80002ac4 <argraw+0x58>
    80002a86:	048a                	slli	s1,s1,0x2
    80002a88:	00006717          	auipc	a4,0x6
    80002a8c:	d5870713          	addi	a4,a4,-680 # 800087e0 <states.0+0x30>
    80002a90:	94ba                	add	s1,s1,a4
    80002a92:	409c                	lw	a5,0(s1)
    80002a94:	97ba                	add	a5,a5,a4
    80002a96:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a98:	6d3c                	ld	a5,88(a0)
    80002a9a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a9c:	60e2                	ld	ra,24(sp)
    80002a9e:	6442                	ld	s0,16(sp)
    80002aa0:	64a2                	ld	s1,8(sp)
    80002aa2:	6105                	addi	sp,sp,32
    80002aa4:	8082                	ret
    return p->trapframe->a1;
    80002aa6:	6d3c                	ld	a5,88(a0)
    80002aa8:	7fa8                	ld	a0,120(a5)
    80002aaa:	bfcd                	j	80002a9c <argraw+0x30>
    return p->trapframe->a2;
    80002aac:	6d3c                	ld	a5,88(a0)
    80002aae:	63c8                	ld	a0,128(a5)
    80002ab0:	b7f5                	j	80002a9c <argraw+0x30>
    return p->trapframe->a3;
    80002ab2:	6d3c                	ld	a5,88(a0)
    80002ab4:	67c8                	ld	a0,136(a5)
    80002ab6:	b7dd                	j	80002a9c <argraw+0x30>
    return p->trapframe->a4;
    80002ab8:	6d3c                	ld	a5,88(a0)
    80002aba:	6bc8                	ld	a0,144(a5)
    80002abc:	b7c5                	j	80002a9c <argraw+0x30>
    return p->trapframe->a5;
    80002abe:	6d3c                	ld	a5,88(a0)
    80002ac0:	6fc8                	ld	a0,152(a5)
    80002ac2:	bfe9                	j	80002a9c <argraw+0x30>
  panic("argraw");
    80002ac4:	00006517          	auipc	a0,0x6
    80002ac8:	8fc50513          	addi	a0,a0,-1796 # 800083c0 <etext+0x3c0>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	a94080e7          	jalr	-1388(ra) # 80000560 <panic>

0000000080002ad4 <fetchaddr>:
{
    80002ad4:	1101                	addi	sp,sp,-32
    80002ad6:	ec06                	sd	ra,24(sp)
    80002ad8:	e822                	sd	s0,16(sp)
    80002ada:	e426                	sd	s1,8(sp)
    80002adc:	e04a                	sd	s2,0(sp)
    80002ade:	1000                	addi	s0,sp,32
    80002ae0:	84aa                	mv	s1,a0
    80002ae2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ae4:	fffff097          	auipc	ra,0xfffff
    80002ae8:	f6e080e7          	jalr	-146(ra) # 80001a52 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002aec:	653c                	ld	a5,72(a0)
    80002aee:	02f4f863          	bgeu	s1,a5,80002b1e <fetchaddr+0x4a>
    80002af2:	00848713          	addi	a4,s1,8
    80002af6:	02e7e663          	bltu	a5,a4,80002b22 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002afa:	46a1                	li	a3,8
    80002afc:	8626                	mv	a2,s1
    80002afe:	85ca                	mv	a1,s2
    80002b00:	6928                	ld	a0,80(a0)
    80002b02:	fffff097          	auipc	ra,0xfffff
    80002b06:	c74080e7          	jalr	-908(ra) # 80001776 <copyin>
    80002b0a:	00a03533          	snez	a0,a0
    80002b0e:	40a00533          	neg	a0,a0
}
    80002b12:	60e2                	ld	ra,24(sp)
    80002b14:	6442                	ld	s0,16(sp)
    80002b16:	64a2                	ld	s1,8(sp)
    80002b18:	6902                	ld	s2,0(sp)
    80002b1a:	6105                	addi	sp,sp,32
    80002b1c:	8082                	ret
    return -1;
    80002b1e:	557d                	li	a0,-1
    80002b20:	bfcd                	j	80002b12 <fetchaddr+0x3e>
    80002b22:	557d                	li	a0,-1
    80002b24:	b7fd                	j	80002b12 <fetchaddr+0x3e>

0000000080002b26 <fetchstr>:
{
    80002b26:	7179                	addi	sp,sp,-48
    80002b28:	f406                	sd	ra,40(sp)
    80002b2a:	f022                	sd	s0,32(sp)
    80002b2c:	ec26                	sd	s1,24(sp)
    80002b2e:	e84a                	sd	s2,16(sp)
    80002b30:	e44e                	sd	s3,8(sp)
    80002b32:	1800                	addi	s0,sp,48
    80002b34:	892a                	mv	s2,a0
    80002b36:	84ae                	mv	s1,a1
    80002b38:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b3a:	fffff097          	auipc	ra,0xfffff
    80002b3e:	f18080e7          	jalr	-232(ra) # 80001a52 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b42:	86ce                	mv	a3,s3
    80002b44:	864a                	mv	a2,s2
    80002b46:	85a6                	mv	a1,s1
    80002b48:	6928                	ld	a0,80(a0)
    80002b4a:	fffff097          	auipc	ra,0xfffff
    80002b4e:	cba080e7          	jalr	-838(ra) # 80001804 <copyinstr>
    80002b52:	00054e63          	bltz	a0,80002b6e <fetchstr+0x48>
  return strlen(buf);
    80002b56:	8526                	mv	a0,s1
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	350080e7          	jalr	848(ra) # 80000ea8 <strlen>
}
    80002b60:	70a2                	ld	ra,40(sp)
    80002b62:	7402                	ld	s0,32(sp)
    80002b64:	64e2                	ld	s1,24(sp)
    80002b66:	6942                	ld	s2,16(sp)
    80002b68:	69a2                	ld	s3,8(sp)
    80002b6a:	6145                	addi	sp,sp,48
    80002b6c:	8082                	ret
    return -1;
    80002b6e:	557d                	li	a0,-1
    80002b70:	bfc5                	j	80002b60 <fetchstr+0x3a>

0000000080002b72 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b72:	1101                	addi	sp,sp,-32
    80002b74:	ec06                	sd	ra,24(sp)
    80002b76:	e822                	sd	s0,16(sp)
    80002b78:	e426                	sd	s1,8(sp)
    80002b7a:	1000                	addi	s0,sp,32
    80002b7c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b7e:	00000097          	auipc	ra,0x0
    80002b82:	eee080e7          	jalr	-274(ra) # 80002a6c <argraw>
    80002b86:	c088                	sw	a0,0(s1)
}
    80002b88:	60e2                	ld	ra,24(sp)
    80002b8a:	6442                	ld	s0,16(sp)
    80002b8c:	64a2                	ld	s1,8(sp)
    80002b8e:	6105                	addi	sp,sp,32
    80002b90:	8082                	ret

0000000080002b92 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b92:	1101                	addi	sp,sp,-32
    80002b94:	ec06                	sd	ra,24(sp)
    80002b96:	e822                	sd	s0,16(sp)
    80002b98:	e426                	sd	s1,8(sp)
    80002b9a:	1000                	addi	s0,sp,32
    80002b9c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b9e:	00000097          	auipc	ra,0x0
    80002ba2:	ece080e7          	jalr	-306(ra) # 80002a6c <argraw>
    80002ba6:	e088                	sd	a0,0(s1)
}
    80002ba8:	60e2                	ld	ra,24(sp)
    80002baa:	6442                	ld	s0,16(sp)
    80002bac:	64a2                	ld	s1,8(sp)
    80002bae:	6105                	addi	sp,sp,32
    80002bb0:	8082                	ret

0000000080002bb2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bb2:	7179                	addi	sp,sp,-48
    80002bb4:	f406                	sd	ra,40(sp)
    80002bb6:	f022                	sd	s0,32(sp)
    80002bb8:	ec26                	sd	s1,24(sp)
    80002bba:	e84a                	sd	s2,16(sp)
    80002bbc:	1800                	addi	s0,sp,48
    80002bbe:	84ae                	mv	s1,a1
    80002bc0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002bc2:	fd840593          	addi	a1,s0,-40
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	fcc080e7          	jalr	-52(ra) # 80002b92 <argaddr>
  return fetchstr(addr, buf, max);
    80002bce:	864a                	mv	a2,s2
    80002bd0:	85a6                	mv	a1,s1
    80002bd2:	fd843503          	ld	a0,-40(s0)
    80002bd6:	00000097          	auipc	ra,0x0
    80002bda:	f50080e7          	jalr	-176(ra) # 80002b26 <fetchstr>
}
    80002bde:	70a2                	ld	ra,40(sp)
    80002be0:	7402                	ld	s0,32(sp)
    80002be2:	64e2                	ld	s1,24(sp)
    80002be4:	6942                	ld	s2,16(sp)
    80002be6:	6145                	addi	sp,sp,48
    80002be8:	8082                	ret

0000000080002bea <syscall>:
[SYS_sem_down]  sys_sem_down,
};

void
syscall(void)
{
    80002bea:	1101                	addi	sp,sp,-32
    80002bec:	ec06                	sd	ra,24(sp)
    80002bee:	e822                	sd	s0,16(sp)
    80002bf0:	e426                	sd	s1,8(sp)
    80002bf2:	e04a                	sd	s2,0(sp)
    80002bf4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	e5c080e7          	jalr	-420(ra) # 80001a52 <myproc>
    80002bfe:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c00:	05853903          	ld	s2,88(a0)
    80002c04:	0a893783          	ld	a5,168(s2)
    80002c08:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c0c:	37fd                	addiw	a5,a5,-1
    80002c0e:	4761                	li	a4,24
    80002c10:	00f76f63          	bltu	a4,a5,80002c2e <syscall+0x44>
    80002c14:	00369713          	slli	a4,a3,0x3
    80002c18:	00006797          	auipc	a5,0x6
    80002c1c:	be078793          	addi	a5,a5,-1056 # 800087f8 <syscalls>
    80002c20:	97ba                	add	a5,a5,a4
    80002c22:	639c                	ld	a5,0(a5)
    80002c24:	c789                	beqz	a5,80002c2e <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c26:	9782                	jalr	a5
    80002c28:	06a93823          	sd	a0,112(s2)
    80002c2c:	a839                	j	80002c4a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c2e:	15848613          	addi	a2,s1,344
    80002c32:	588c                	lw	a1,48(s1)
    80002c34:	00005517          	auipc	a0,0x5
    80002c38:	79450513          	addi	a0,a0,1940 # 800083c8 <etext+0x3c8>
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	96e080e7          	jalr	-1682(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c44:	6cbc                	ld	a5,88(s1)
    80002c46:	577d                	li	a4,-1
    80002c48:	fbb8                	sd	a4,112(a5)
  }
}
    80002c4a:	60e2                	ld	ra,24(sp)
    80002c4c:	6442                	ld	s0,16(sp)
    80002c4e:	64a2                	ld	s1,8(sp)
    80002c50:	6902                	ld	s2,0(sp)
    80002c52:	6105                	addi	sp,sp,32
    80002c54:	8082                	ret

0000000080002c56 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c56:	1101                	addi	sp,sp,-32
    80002c58:	ec06                	sd	ra,24(sp)
    80002c5a:	e822                	sd	s0,16(sp)
    80002c5c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c5e:	fec40593          	addi	a1,s0,-20
    80002c62:	4501                	li	a0,0
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	f0e080e7          	jalr	-242(ra) # 80002b72 <argint>
  exit(n);
    80002c6c:	fec42503          	lw	a0,-20(s0)
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	5c0080e7          	jalr	1472(ra) # 80002230 <exit>
  return 0;  // not reached
}
    80002c78:	4501                	li	a0,0
    80002c7a:	60e2                	ld	ra,24(sp)
    80002c7c:	6442                	ld	s0,16(sp)
    80002c7e:	6105                	addi	sp,sp,32
    80002c80:	8082                	ret

0000000080002c82 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c82:	1141                	addi	sp,sp,-16
    80002c84:	e406                	sd	ra,8(sp)
    80002c86:	e022                	sd	s0,0(sp)
    80002c88:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c8a:	fffff097          	auipc	ra,0xfffff
    80002c8e:	dc8080e7          	jalr	-568(ra) # 80001a52 <myproc>
}
    80002c92:	5908                	lw	a0,48(a0)
    80002c94:	60a2                	ld	ra,8(sp)
    80002c96:	6402                	ld	s0,0(sp)
    80002c98:	0141                	addi	sp,sp,16
    80002c9a:	8082                	ret

0000000080002c9c <sys_fork>:

uint64
sys_fork(void)
{
    80002c9c:	1141                	addi	sp,sp,-16
    80002c9e:	e406                	sd	ra,8(sp)
    80002ca0:	e022                	sd	s0,0(sp)
    80002ca2:	0800                	addi	s0,sp,16
  return fork();
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	164080e7          	jalr	356(ra) # 80001e08 <fork>
}
    80002cac:	60a2                	ld	ra,8(sp)
    80002cae:	6402                	ld	s0,0(sp)
    80002cb0:	0141                	addi	sp,sp,16
    80002cb2:	8082                	ret

0000000080002cb4 <sys_wait>:

uint64
sys_wait(void)
{
    80002cb4:	1101                	addi	sp,sp,-32
    80002cb6:	ec06                	sd	ra,24(sp)
    80002cb8:	e822                	sd	s0,16(sp)
    80002cba:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002cbc:	fe840593          	addi	a1,s0,-24
    80002cc0:	4501                	li	a0,0
    80002cc2:	00000097          	auipc	ra,0x0
    80002cc6:	ed0080e7          	jalr	-304(ra) # 80002b92 <argaddr>
  return wait(p);
    80002cca:	fe843503          	ld	a0,-24(s0)
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	708080e7          	jalr	1800(ra) # 800023d6 <wait>
}
    80002cd6:	60e2                	ld	ra,24(sp)
    80002cd8:	6442                	ld	s0,16(sp)
    80002cda:	6105                	addi	sp,sp,32
    80002cdc:	8082                	ret

0000000080002cde <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cde:	7179                	addi	sp,sp,-48
    80002ce0:	f406                	sd	ra,40(sp)
    80002ce2:	f022                	sd	s0,32(sp)
    80002ce4:	ec26                	sd	s1,24(sp)
    80002ce6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ce8:	fdc40593          	addi	a1,s0,-36
    80002cec:	4501                	li	a0,0
    80002cee:	00000097          	auipc	ra,0x0
    80002cf2:	e84080e7          	jalr	-380(ra) # 80002b72 <argint>
  addr = myproc()->sz;
    80002cf6:	fffff097          	auipc	ra,0xfffff
    80002cfa:	d5c080e7          	jalr	-676(ra) # 80001a52 <myproc>
    80002cfe:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d00:	fdc42503          	lw	a0,-36(s0)
    80002d04:	fffff097          	auipc	ra,0xfffff
    80002d08:	0a8080e7          	jalr	168(ra) # 80001dac <growproc>
    80002d0c:	00054863          	bltz	a0,80002d1c <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002d10:	8526                	mv	a0,s1
    80002d12:	70a2                	ld	ra,40(sp)
    80002d14:	7402                	ld	s0,32(sp)
    80002d16:	64e2                	ld	s1,24(sp)
    80002d18:	6145                	addi	sp,sp,48
    80002d1a:	8082                	ret
    return -1;
    80002d1c:	54fd                	li	s1,-1
    80002d1e:	bfcd                	j	80002d10 <sys_sbrk+0x32>

0000000080002d20 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d20:	7139                	addi	sp,sp,-64
    80002d22:	fc06                	sd	ra,56(sp)
    80002d24:	f822                	sd	s0,48(sp)
    80002d26:	f04a                	sd	s2,32(sp)
    80002d28:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d2a:	fcc40593          	addi	a1,s0,-52
    80002d2e:	4501                	li	a0,0
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	e42080e7          	jalr	-446(ra) # 80002b72 <argint>
  acquire(&tickslock);
    80002d38:	00016517          	auipc	a0,0x16
    80002d3c:	75850513          	addi	a0,a0,1880 # 80019490 <tickslock>
    80002d40:	ffffe097          	auipc	ra,0xffffe
    80002d44:	ef8080e7          	jalr	-264(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80002d48:	00008917          	auipc	s2,0x8
    80002d4c:	6a892903          	lw	s2,1704(s2) # 8000b3f0 <ticks>
  while(ticks - ticks0 < n){
    80002d50:	fcc42783          	lw	a5,-52(s0)
    80002d54:	c3b9                	beqz	a5,80002d9a <sys_sleep+0x7a>
    80002d56:	f426                	sd	s1,40(sp)
    80002d58:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d5a:	00016997          	auipc	s3,0x16
    80002d5e:	73698993          	addi	s3,s3,1846 # 80019490 <tickslock>
    80002d62:	00008497          	auipc	s1,0x8
    80002d66:	68e48493          	addi	s1,s1,1678 # 8000b3f0 <ticks>
    if(killed(myproc())){
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	ce8080e7          	jalr	-792(ra) # 80001a52 <myproc>
    80002d72:	fffff097          	auipc	ra,0xfffff
    80002d76:	632080e7          	jalr	1586(ra) # 800023a4 <killed>
    80002d7a:	ed15                	bnez	a0,80002db6 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d7c:	85ce                	mv	a1,s3
    80002d7e:	8526                	mv	a0,s1
    80002d80:	fffff097          	auipc	ra,0xfffff
    80002d84:	37c080e7          	jalr	892(ra) # 800020fc <sleep>
  while(ticks - ticks0 < n){
    80002d88:	409c                	lw	a5,0(s1)
    80002d8a:	412787bb          	subw	a5,a5,s2
    80002d8e:	fcc42703          	lw	a4,-52(s0)
    80002d92:	fce7ece3          	bltu	a5,a4,80002d6a <sys_sleep+0x4a>
    80002d96:	74a2                	ld	s1,40(sp)
    80002d98:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d9a:	00016517          	auipc	a0,0x16
    80002d9e:	6f650513          	addi	a0,a0,1782 # 80019490 <tickslock>
    80002da2:	ffffe097          	auipc	ra,0xffffe
    80002da6:	f4a080e7          	jalr	-182(ra) # 80000cec <release>
  return 0;
    80002daa:	4501                	li	a0,0
}
    80002dac:	70e2                	ld	ra,56(sp)
    80002dae:	7442                	ld	s0,48(sp)
    80002db0:	7902                	ld	s2,32(sp)
    80002db2:	6121                	addi	sp,sp,64
    80002db4:	8082                	ret
      release(&tickslock);
    80002db6:	00016517          	auipc	a0,0x16
    80002dba:	6da50513          	addi	a0,a0,1754 # 80019490 <tickslock>
    80002dbe:	ffffe097          	auipc	ra,0xffffe
    80002dc2:	f2e080e7          	jalr	-210(ra) # 80000cec <release>
      return -1;
    80002dc6:	557d                	li	a0,-1
    80002dc8:	74a2                	ld	s1,40(sp)
    80002dca:	69e2                	ld	s3,24(sp)
    80002dcc:	b7c5                	j	80002dac <sys_sleep+0x8c>

0000000080002dce <sys_kill>:

uint64
sys_kill(void)
{
    80002dce:	1101                	addi	sp,sp,-32
    80002dd0:	ec06                	sd	ra,24(sp)
    80002dd2:	e822                	sd	s0,16(sp)
    80002dd4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002dd6:	fec40593          	addi	a1,s0,-20
    80002dda:	4501                	li	a0,0
    80002ddc:	00000097          	auipc	ra,0x0
    80002de0:	d96080e7          	jalr	-618(ra) # 80002b72 <argint>
  return kill(pid);
    80002de4:	fec42503          	lw	a0,-20(s0)
    80002de8:	fffff097          	auipc	ra,0xfffff
    80002dec:	51e080e7          	jalr	1310(ra) # 80002306 <kill>
}
    80002df0:	60e2                	ld	ra,24(sp)
    80002df2:	6442                	ld	s0,16(sp)
    80002df4:	6105                	addi	sp,sp,32
    80002df6:	8082                	ret

0000000080002df8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002df8:	1101                	addi	sp,sp,-32
    80002dfa:	ec06                	sd	ra,24(sp)
    80002dfc:	e822                	sd	s0,16(sp)
    80002dfe:	e426                	sd	s1,8(sp)
    80002e00:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e02:	00016517          	auipc	a0,0x16
    80002e06:	68e50513          	addi	a0,a0,1678 # 80019490 <tickslock>
    80002e0a:	ffffe097          	auipc	ra,0xffffe
    80002e0e:	e2e080e7          	jalr	-466(ra) # 80000c38 <acquire>
  xticks = ticks;
    80002e12:	00008497          	auipc	s1,0x8
    80002e16:	5de4a483          	lw	s1,1502(s1) # 8000b3f0 <ticks>
  release(&tickslock);
    80002e1a:	00016517          	auipc	a0,0x16
    80002e1e:	67650513          	addi	a0,a0,1654 # 80019490 <tickslock>
    80002e22:	ffffe097          	auipc	ra,0xffffe
    80002e26:	eca080e7          	jalr	-310(ra) # 80000cec <release>
  return xticks;
}
    80002e2a:	02049513          	slli	a0,s1,0x20
    80002e2e:	9101                	srli	a0,a0,0x20
    80002e30:	60e2                	ld	ra,24(sp)
    80002e32:	6442                	ld	s0,16(sp)
    80002e34:	64a2                	ld	s1,8(sp)
    80002e36:	6105                	addi	sp,sp,32
    80002e38:	8082                	ret

0000000080002e3a <sys_sem_open>:

//semaphores
uint64
sys_sem_open(void)
{
    80002e3a:	1101                	addi	sp,sp,-32
    80002e3c:	ec06                	sd	ra,24(sp)
    80002e3e:	e822                	sd	s0,16(sp)
    80002e40:	1000                	addi	s0,sp,32
    int sem, value;
    argint(0, &sem);
    80002e42:	fec40593          	addi	a1,s0,-20
    80002e46:	4501                	li	a0,0
    80002e48:	00000097          	auipc	ra,0x0
    80002e4c:	d2a080e7          	jalr	-726(ra) # 80002b72 <argint>
    argint(1, &value);
    80002e50:	fe840593          	addi	a1,s0,-24
    80002e54:	4505                	li	a0,1
    80002e56:	00000097          	auipc	ra,0x0
    80002e5a:	d1c080e7          	jalr	-740(ra) # 80002b72 <argint>
    return sem_open(sem, value);
    80002e5e:	fe842583          	lw	a1,-24(s0)
    80002e62:	fec42503          	lw	a0,-20(s0)
    80002e66:	00003097          	auipc	ra,0x3
    80002e6a:	ff6080e7          	jalr	-10(ra) # 80005e5c <sem_open>
}
    80002e6e:	60e2                	ld	ra,24(sp)
    80002e70:	6442                	ld	s0,16(sp)
    80002e72:	6105                	addi	sp,sp,32
    80002e74:	8082                	ret

0000000080002e76 <sys_sem_close>:

uint64
sys_sem_close(void)
{
    80002e76:	1101                	addi	sp,sp,-32
    80002e78:	ec06                	sd	ra,24(sp)
    80002e7a:	e822                	sd	s0,16(sp)
    80002e7c:	1000                	addi	s0,sp,32
    int sem;
    argint(0, &sem);
    80002e7e:	fec40593          	addi	a1,s0,-20
    80002e82:	4501                	li	a0,0
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	cee080e7          	jalr	-786(ra) # 80002b72 <argint>
    return sem_close(sem);
    80002e8c:	fec42503          	lw	a0,-20(s0)
    80002e90:	00003097          	auipc	ra,0x3
    80002e94:	046080e7          	jalr	70(ra) # 80005ed6 <sem_close>
}
    80002e98:	60e2                	ld	ra,24(sp)
    80002e9a:	6442                	ld	s0,16(sp)
    80002e9c:	6105                	addi	sp,sp,32
    80002e9e:	8082                	ret

0000000080002ea0 <sys_sem_up>:

uint64
sys_sem_up(void)
{
    80002ea0:	1101                	addi	sp,sp,-32
    80002ea2:	ec06                	sd	ra,24(sp)
    80002ea4:	e822                	sd	s0,16(sp)
    80002ea6:	1000                	addi	s0,sp,32
    int sem;
    argint(0, &sem);
    80002ea8:	fec40593          	addi	a1,s0,-20
    80002eac:	4501                	li	a0,0
    80002eae:	00000097          	auipc	ra,0x0
    80002eb2:	cc4080e7          	jalr	-828(ra) # 80002b72 <argint>
    return sem_up(sem);
    80002eb6:	fec42503          	lw	a0,-20(s0)
    80002eba:	00003097          	auipc	ra,0x3
    80002ebe:	080080e7          	jalr	128(ra) # 80005f3a <sem_up>
}
    80002ec2:	60e2                	ld	ra,24(sp)
    80002ec4:	6442                	ld	s0,16(sp)
    80002ec6:	6105                	addi	sp,sp,32
    80002ec8:	8082                	ret

0000000080002eca <sys_sem_down>:

uint64
sys_sem_down(void)
{
    80002eca:	1101                	addi	sp,sp,-32
    80002ecc:	ec06                	sd	ra,24(sp)
    80002ece:	e822                	sd	s0,16(sp)
    80002ed0:	1000                	addi	s0,sp,32
    int sem;
    argint(0, &sem);
    80002ed2:	fec40593          	addi	a1,s0,-20
    80002ed6:	4501                	li	a0,0
    80002ed8:	00000097          	auipc	ra,0x0
    80002edc:	c9a080e7          	jalr	-870(ra) # 80002b72 <argint>
    return sem_down(sem);
    80002ee0:	fec42503          	lw	a0,-20(s0)
    80002ee4:	00003097          	auipc	ra,0x3
    80002ee8:	0f2080e7          	jalr	242(ra) # 80005fd6 <sem_down>
}
    80002eec:	60e2                	ld	ra,24(sp)
    80002eee:	6442                	ld	s0,16(sp)
    80002ef0:	6105                	addi	sp,sp,32
    80002ef2:	8082                	ret

0000000080002ef4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ef4:	7179                	addi	sp,sp,-48
    80002ef6:	f406                	sd	ra,40(sp)
    80002ef8:	f022                	sd	s0,32(sp)
    80002efa:	ec26                	sd	s1,24(sp)
    80002efc:	e84a                	sd	s2,16(sp)
    80002efe:	e44e                	sd	s3,8(sp)
    80002f00:	e052                	sd	s4,0(sp)
    80002f02:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f04:	00005597          	auipc	a1,0x5
    80002f08:	4e458593          	addi	a1,a1,1252 # 800083e8 <etext+0x3e8>
    80002f0c:	00016517          	auipc	a0,0x16
    80002f10:	59c50513          	addi	a0,a0,1436 # 800194a8 <bcache>
    80002f14:	ffffe097          	auipc	ra,0xffffe
    80002f18:	c94080e7          	jalr	-876(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f1c:	0001e797          	auipc	a5,0x1e
    80002f20:	58c78793          	addi	a5,a5,1420 # 800214a8 <bcache+0x8000>
    80002f24:	0001e717          	auipc	a4,0x1e
    80002f28:	7ec70713          	addi	a4,a4,2028 # 80021710 <bcache+0x8268>
    80002f2c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f30:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f34:	00016497          	auipc	s1,0x16
    80002f38:	58c48493          	addi	s1,s1,1420 # 800194c0 <bcache+0x18>
    b->next = bcache.head.next;
    80002f3c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f3e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f40:	00005a17          	auipc	s4,0x5
    80002f44:	4b0a0a13          	addi	s4,s4,1200 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    80002f48:	2b893783          	ld	a5,696(s2)
    80002f4c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f4e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f52:	85d2                	mv	a1,s4
    80002f54:	01048513          	addi	a0,s1,16
    80002f58:	00001097          	auipc	ra,0x1
    80002f5c:	4e8080e7          	jalr	1256(ra) # 80004440 <initsleeplock>
    bcache.head.next->prev = b;
    80002f60:	2b893783          	ld	a5,696(s2)
    80002f64:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f66:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f6a:	45848493          	addi	s1,s1,1112
    80002f6e:	fd349de3          	bne	s1,s3,80002f48 <binit+0x54>
  }
}
    80002f72:	70a2                	ld	ra,40(sp)
    80002f74:	7402                	ld	s0,32(sp)
    80002f76:	64e2                	ld	s1,24(sp)
    80002f78:	6942                	ld	s2,16(sp)
    80002f7a:	69a2                	ld	s3,8(sp)
    80002f7c:	6a02                	ld	s4,0(sp)
    80002f7e:	6145                	addi	sp,sp,48
    80002f80:	8082                	ret

0000000080002f82 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f82:	7179                	addi	sp,sp,-48
    80002f84:	f406                	sd	ra,40(sp)
    80002f86:	f022                	sd	s0,32(sp)
    80002f88:	ec26                	sd	s1,24(sp)
    80002f8a:	e84a                	sd	s2,16(sp)
    80002f8c:	e44e                	sd	s3,8(sp)
    80002f8e:	1800                	addi	s0,sp,48
    80002f90:	892a                	mv	s2,a0
    80002f92:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f94:	00016517          	auipc	a0,0x16
    80002f98:	51450513          	addi	a0,a0,1300 # 800194a8 <bcache>
    80002f9c:	ffffe097          	auipc	ra,0xffffe
    80002fa0:	c9c080e7          	jalr	-868(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fa4:	0001e497          	auipc	s1,0x1e
    80002fa8:	7bc4b483          	ld	s1,1980(s1) # 80021760 <bcache+0x82b8>
    80002fac:	0001e797          	auipc	a5,0x1e
    80002fb0:	76478793          	addi	a5,a5,1892 # 80021710 <bcache+0x8268>
    80002fb4:	02f48f63          	beq	s1,a5,80002ff2 <bread+0x70>
    80002fb8:	873e                	mv	a4,a5
    80002fba:	a021                	j	80002fc2 <bread+0x40>
    80002fbc:	68a4                	ld	s1,80(s1)
    80002fbe:	02e48a63          	beq	s1,a4,80002ff2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fc2:	449c                	lw	a5,8(s1)
    80002fc4:	ff279ce3          	bne	a5,s2,80002fbc <bread+0x3a>
    80002fc8:	44dc                	lw	a5,12(s1)
    80002fca:	ff3799e3          	bne	a5,s3,80002fbc <bread+0x3a>
      b->refcnt++;
    80002fce:	40bc                	lw	a5,64(s1)
    80002fd0:	2785                	addiw	a5,a5,1
    80002fd2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fd4:	00016517          	auipc	a0,0x16
    80002fd8:	4d450513          	addi	a0,a0,1236 # 800194a8 <bcache>
    80002fdc:	ffffe097          	auipc	ra,0xffffe
    80002fe0:	d10080e7          	jalr	-752(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80002fe4:	01048513          	addi	a0,s1,16
    80002fe8:	00001097          	auipc	ra,0x1
    80002fec:	492080e7          	jalr	1170(ra) # 8000447a <acquiresleep>
      return b;
    80002ff0:	a8b9                	j	8000304e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ff2:	0001e497          	auipc	s1,0x1e
    80002ff6:	7664b483          	ld	s1,1894(s1) # 80021758 <bcache+0x82b0>
    80002ffa:	0001e797          	auipc	a5,0x1e
    80002ffe:	71678793          	addi	a5,a5,1814 # 80021710 <bcache+0x8268>
    80003002:	00f48863          	beq	s1,a5,80003012 <bread+0x90>
    80003006:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003008:	40bc                	lw	a5,64(s1)
    8000300a:	cf81                	beqz	a5,80003022 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000300c:	64a4                	ld	s1,72(s1)
    8000300e:	fee49de3          	bne	s1,a4,80003008 <bread+0x86>
  panic("bget: no buffers");
    80003012:	00005517          	auipc	a0,0x5
    80003016:	3e650513          	addi	a0,a0,998 # 800083f8 <etext+0x3f8>
    8000301a:	ffffd097          	auipc	ra,0xffffd
    8000301e:	546080e7          	jalr	1350(ra) # 80000560 <panic>
      b->dev = dev;
    80003022:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003026:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000302a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000302e:	4785                	li	a5,1
    80003030:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003032:	00016517          	auipc	a0,0x16
    80003036:	47650513          	addi	a0,a0,1142 # 800194a8 <bcache>
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	cb2080e7          	jalr	-846(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003042:	01048513          	addi	a0,s1,16
    80003046:	00001097          	auipc	ra,0x1
    8000304a:	434080e7          	jalr	1076(ra) # 8000447a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000304e:	409c                	lw	a5,0(s1)
    80003050:	cb89                	beqz	a5,80003062 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003052:	8526                	mv	a0,s1
    80003054:	70a2                	ld	ra,40(sp)
    80003056:	7402                	ld	s0,32(sp)
    80003058:	64e2                	ld	s1,24(sp)
    8000305a:	6942                	ld	s2,16(sp)
    8000305c:	69a2                	ld	s3,8(sp)
    8000305e:	6145                	addi	sp,sp,48
    80003060:	8082                	ret
    virtio_disk_rw(b, 0);
    80003062:	4581                	li	a1,0
    80003064:	8526                	mv	a0,s1
    80003066:	00003097          	auipc	ra,0x3
    8000306a:	358080e7          	jalr	856(ra) # 800063be <virtio_disk_rw>
    b->valid = 1;
    8000306e:	4785                	li	a5,1
    80003070:	c09c                	sw	a5,0(s1)
  return b;
    80003072:	b7c5                	j	80003052 <bread+0xd0>

0000000080003074 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003074:	1101                	addi	sp,sp,-32
    80003076:	ec06                	sd	ra,24(sp)
    80003078:	e822                	sd	s0,16(sp)
    8000307a:	e426                	sd	s1,8(sp)
    8000307c:	1000                	addi	s0,sp,32
    8000307e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003080:	0541                	addi	a0,a0,16
    80003082:	00001097          	auipc	ra,0x1
    80003086:	492080e7          	jalr	1170(ra) # 80004514 <holdingsleep>
    8000308a:	cd01                	beqz	a0,800030a2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000308c:	4585                	li	a1,1
    8000308e:	8526                	mv	a0,s1
    80003090:	00003097          	auipc	ra,0x3
    80003094:	32e080e7          	jalr	814(ra) # 800063be <virtio_disk_rw>
}
    80003098:	60e2                	ld	ra,24(sp)
    8000309a:	6442                	ld	s0,16(sp)
    8000309c:	64a2                	ld	s1,8(sp)
    8000309e:	6105                	addi	sp,sp,32
    800030a0:	8082                	ret
    panic("bwrite");
    800030a2:	00005517          	auipc	a0,0x5
    800030a6:	36e50513          	addi	a0,a0,878 # 80008410 <etext+0x410>
    800030aa:	ffffd097          	auipc	ra,0xffffd
    800030ae:	4b6080e7          	jalr	1206(ra) # 80000560 <panic>

00000000800030b2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030b2:	1101                	addi	sp,sp,-32
    800030b4:	ec06                	sd	ra,24(sp)
    800030b6:	e822                	sd	s0,16(sp)
    800030b8:	e426                	sd	s1,8(sp)
    800030ba:	e04a                	sd	s2,0(sp)
    800030bc:	1000                	addi	s0,sp,32
    800030be:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030c0:	01050913          	addi	s2,a0,16
    800030c4:	854a                	mv	a0,s2
    800030c6:	00001097          	auipc	ra,0x1
    800030ca:	44e080e7          	jalr	1102(ra) # 80004514 <holdingsleep>
    800030ce:	c925                	beqz	a0,8000313e <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800030d0:	854a                	mv	a0,s2
    800030d2:	00001097          	auipc	ra,0x1
    800030d6:	3fe080e7          	jalr	1022(ra) # 800044d0 <releasesleep>

  acquire(&bcache.lock);
    800030da:	00016517          	auipc	a0,0x16
    800030de:	3ce50513          	addi	a0,a0,974 # 800194a8 <bcache>
    800030e2:	ffffe097          	auipc	ra,0xffffe
    800030e6:	b56080e7          	jalr	-1194(ra) # 80000c38 <acquire>
  b->refcnt--;
    800030ea:	40bc                	lw	a5,64(s1)
    800030ec:	37fd                	addiw	a5,a5,-1
    800030ee:	0007871b          	sext.w	a4,a5
    800030f2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030f4:	e71d                	bnez	a4,80003122 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030f6:	68b8                	ld	a4,80(s1)
    800030f8:	64bc                	ld	a5,72(s1)
    800030fa:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030fc:	68b8                	ld	a4,80(s1)
    800030fe:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003100:	0001e797          	auipc	a5,0x1e
    80003104:	3a878793          	addi	a5,a5,936 # 800214a8 <bcache+0x8000>
    80003108:	2b87b703          	ld	a4,696(a5)
    8000310c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000310e:	0001e717          	auipc	a4,0x1e
    80003112:	60270713          	addi	a4,a4,1538 # 80021710 <bcache+0x8268>
    80003116:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003118:	2b87b703          	ld	a4,696(a5)
    8000311c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000311e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003122:	00016517          	auipc	a0,0x16
    80003126:	38650513          	addi	a0,a0,902 # 800194a8 <bcache>
    8000312a:	ffffe097          	auipc	ra,0xffffe
    8000312e:	bc2080e7          	jalr	-1086(ra) # 80000cec <release>
}
    80003132:	60e2                	ld	ra,24(sp)
    80003134:	6442                	ld	s0,16(sp)
    80003136:	64a2                	ld	s1,8(sp)
    80003138:	6902                	ld	s2,0(sp)
    8000313a:	6105                	addi	sp,sp,32
    8000313c:	8082                	ret
    panic("brelse");
    8000313e:	00005517          	auipc	a0,0x5
    80003142:	2da50513          	addi	a0,a0,730 # 80008418 <etext+0x418>
    80003146:	ffffd097          	auipc	ra,0xffffd
    8000314a:	41a080e7          	jalr	1050(ra) # 80000560 <panic>

000000008000314e <bpin>:

void
bpin(struct buf *b) {
    8000314e:	1101                	addi	sp,sp,-32
    80003150:	ec06                	sd	ra,24(sp)
    80003152:	e822                	sd	s0,16(sp)
    80003154:	e426                	sd	s1,8(sp)
    80003156:	1000                	addi	s0,sp,32
    80003158:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000315a:	00016517          	auipc	a0,0x16
    8000315e:	34e50513          	addi	a0,a0,846 # 800194a8 <bcache>
    80003162:	ffffe097          	auipc	ra,0xffffe
    80003166:	ad6080e7          	jalr	-1322(ra) # 80000c38 <acquire>
  b->refcnt++;
    8000316a:	40bc                	lw	a5,64(s1)
    8000316c:	2785                	addiw	a5,a5,1
    8000316e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003170:	00016517          	auipc	a0,0x16
    80003174:	33850513          	addi	a0,a0,824 # 800194a8 <bcache>
    80003178:	ffffe097          	auipc	ra,0xffffe
    8000317c:	b74080e7          	jalr	-1164(ra) # 80000cec <release>
}
    80003180:	60e2                	ld	ra,24(sp)
    80003182:	6442                	ld	s0,16(sp)
    80003184:	64a2                	ld	s1,8(sp)
    80003186:	6105                	addi	sp,sp,32
    80003188:	8082                	ret

000000008000318a <bunpin>:

void
bunpin(struct buf *b) {
    8000318a:	1101                	addi	sp,sp,-32
    8000318c:	ec06                	sd	ra,24(sp)
    8000318e:	e822                	sd	s0,16(sp)
    80003190:	e426                	sd	s1,8(sp)
    80003192:	1000                	addi	s0,sp,32
    80003194:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003196:	00016517          	auipc	a0,0x16
    8000319a:	31250513          	addi	a0,a0,786 # 800194a8 <bcache>
    8000319e:	ffffe097          	auipc	ra,0xffffe
    800031a2:	a9a080e7          	jalr	-1382(ra) # 80000c38 <acquire>
  b->refcnt--;
    800031a6:	40bc                	lw	a5,64(s1)
    800031a8:	37fd                	addiw	a5,a5,-1
    800031aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031ac:	00016517          	auipc	a0,0x16
    800031b0:	2fc50513          	addi	a0,a0,764 # 800194a8 <bcache>
    800031b4:	ffffe097          	auipc	ra,0xffffe
    800031b8:	b38080e7          	jalr	-1224(ra) # 80000cec <release>
}
    800031bc:	60e2                	ld	ra,24(sp)
    800031be:	6442                	ld	s0,16(sp)
    800031c0:	64a2                	ld	s1,8(sp)
    800031c2:	6105                	addi	sp,sp,32
    800031c4:	8082                	ret

00000000800031c6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031c6:	1101                	addi	sp,sp,-32
    800031c8:	ec06                	sd	ra,24(sp)
    800031ca:	e822                	sd	s0,16(sp)
    800031cc:	e426                	sd	s1,8(sp)
    800031ce:	e04a                	sd	s2,0(sp)
    800031d0:	1000                	addi	s0,sp,32
    800031d2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031d4:	00d5d59b          	srliw	a1,a1,0xd
    800031d8:	0001f797          	auipc	a5,0x1f
    800031dc:	9ac7a783          	lw	a5,-1620(a5) # 80021b84 <sb+0x1c>
    800031e0:	9dbd                	addw	a1,a1,a5
    800031e2:	00000097          	auipc	ra,0x0
    800031e6:	da0080e7          	jalr	-608(ra) # 80002f82 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031ea:	0074f713          	andi	a4,s1,7
    800031ee:	4785                	li	a5,1
    800031f0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031f4:	14ce                	slli	s1,s1,0x33
    800031f6:	90d9                	srli	s1,s1,0x36
    800031f8:	00950733          	add	a4,a0,s1
    800031fc:	05874703          	lbu	a4,88(a4)
    80003200:	00e7f6b3          	and	a3,a5,a4
    80003204:	c69d                	beqz	a3,80003232 <bfree+0x6c>
    80003206:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003208:	94aa                	add	s1,s1,a0
    8000320a:	fff7c793          	not	a5,a5
    8000320e:	8f7d                	and	a4,a4,a5
    80003210:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003214:	00001097          	auipc	ra,0x1
    80003218:	148080e7          	jalr	328(ra) # 8000435c <log_write>
  brelse(bp);
    8000321c:	854a                	mv	a0,s2
    8000321e:	00000097          	auipc	ra,0x0
    80003222:	e94080e7          	jalr	-364(ra) # 800030b2 <brelse>
}
    80003226:	60e2                	ld	ra,24(sp)
    80003228:	6442                	ld	s0,16(sp)
    8000322a:	64a2                	ld	s1,8(sp)
    8000322c:	6902                	ld	s2,0(sp)
    8000322e:	6105                	addi	sp,sp,32
    80003230:	8082                	ret
    panic("freeing free block");
    80003232:	00005517          	auipc	a0,0x5
    80003236:	1ee50513          	addi	a0,a0,494 # 80008420 <etext+0x420>
    8000323a:	ffffd097          	auipc	ra,0xffffd
    8000323e:	326080e7          	jalr	806(ra) # 80000560 <panic>

0000000080003242 <balloc>:
{
    80003242:	711d                	addi	sp,sp,-96
    80003244:	ec86                	sd	ra,88(sp)
    80003246:	e8a2                	sd	s0,80(sp)
    80003248:	e4a6                	sd	s1,72(sp)
    8000324a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000324c:	0001f797          	auipc	a5,0x1f
    80003250:	9207a783          	lw	a5,-1760(a5) # 80021b6c <sb+0x4>
    80003254:	10078f63          	beqz	a5,80003372 <balloc+0x130>
    80003258:	e0ca                	sd	s2,64(sp)
    8000325a:	fc4e                	sd	s3,56(sp)
    8000325c:	f852                	sd	s4,48(sp)
    8000325e:	f456                	sd	s5,40(sp)
    80003260:	f05a                	sd	s6,32(sp)
    80003262:	ec5e                	sd	s7,24(sp)
    80003264:	e862                	sd	s8,16(sp)
    80003266:	e466                	sd	s9,8(sp)
    80003268:	8baa                	mv	s7,a0
    8000326a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000326c:	0001fb17          	auipc	s6,0x1f
    80003270:	8fcb0b13          	addi	s6,s6,-1796 # 80021b68 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003274:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003276:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003278:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000327a:	6c89                	lui	s9,0x2
    8000327c:	a061                	j	80003304 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000327e:	97ca                	add	a5,a5,s2
    80003280:	8e55                	or	a2,a2,a3
    80003282:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003286:	854a                	mv	a0,s2
    80003288:	00001097          	auipc	ra,0x1
    8000328c:	0d4080e7          	jalr	212(ra) # 8000435c <log_write>
        brelse(bp);
    80003290:	854a                	mv	a0,s2
    80003292:	00000097          	auipc	ra,0x0
    80003296:	e20080e7          	jalr	-480(ra) # 800030b2 <brelse>
  bp = bread(dev, bno);
    8000329a:	85a6                	mv	a1,s1
    8000329c:	855e                	mv	a0,s7
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	ce4080e7          	jalr	-796(ra) # 80002f82 <bread>
    800032a6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032a8:	40000613          	li	a2,1024
    800032ac:	4581                	li	a1,0
    800032ae:	05850513          	addi	a0,a0,88
    800032b2:	ffffe097          	auipc	ra,0xffffe
    800032b6:	a82080e7          	jalr	-1406(ra) # 80000d34 <memset>
  log_write(bp);
    800032ba:	854a                	mv	a0,s2
    800032bc:	00001097          	auipc	ra,0x1
    800032c0:	0a0080e7          	jalr	160(ra) # 8000435c <log_write>
  brelse(bp);
    800032c4:	854a                	mv	a0,s2
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	dec080e7          	jalr	-532(ra) # 800030b2 <brelse>
}
    800032ce:	6906                	ld	s2,64(sp)
    800032d0:	79e2                	ld	s3,56(sp)
    800032d2:	7a42                	ld	s4,48(sp)
    800032d4:	7aa2                	ld	s5,40(sp)
    800032d6:	7b02                	ld	s6,32(sp)
    800032d8:	6be2                	ld	s7,24(sp)
    800032da:	6c42                	ld	s8,16(sp)
    800032dc:	6ca2                	ld	s9,8(sp)
}
    800032de:	8526                	mv	a0,s1
    800032e0:	60e6                	ld	ra,88(sp)
    800032e2:	6446                	ld	s0,80(sp)
    800032e4:	64a6                	ld	s1,72(sp)
    800032e6:	6125                	addi	sp,sp,96
    800032e8:	8082                	ret
    brelse(bp);
    800032ea:	854a                	mv	a0,s2
    800032ec:	00000097          	auipc	ra,0x0
    800032f0:	dc6080e7          	jalr	-570(ra) # 800030b2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032f4:	015c87bb          	addw	a5,s9,s5
    800032f8:	00078a9b          	sext.w	s5,a5
    800032fc:	004b2703          	lw	a4,4(s6)
    80003300:	06eaf163          	bgeu	s5,a4,80003362 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003304:	41fad79b          	sraiw	a5,s5,0x1f
    80003308:	0137d79b          	srliw	a5,a5,0x13
    8000330c:	015787bb          	addw	a5,a5,s5
    80003310:	40d7d79b          	sraiw	a5,a5,0xd
    80003314:	01cb2583          	lw	a1,28(s6)
    80003318:	9dbd                	addw	a1,a1,a5
    8000331a:	855e                	mv	a0,s7
    8000331c:	00000097          	auipc	ra,0x0
    80003320:	c66080e7          	jalr	-922(ra) # 80002f82 <bread>
    80003324:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003326:	004b2503          	lw	a0,4(s6)
    8000332a:	000a849b          	sext.w	s1,s5
    8000332e:	8762                	mv	a4,s8
    80003330:	faa4fde3          	bgeu	s1,a0,800032ea <balloc+0xa8>
      m = 1 << (bi % 8);
    80003334:	00777693          	andi	a3,a4,7
    80003338:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000333c:	41f7579b          	sraiw	a5,a4,0x1f
    80003340:	01d7d79b          	srliw	a5,a5,0x1d
    80003344:	9fb9                	addw	a5,a5,a4
    80003346:	4037d79b          	sraiw	a5,a5,0x3
    8000334a:	00f90633          	add	a2,s2,a5
    8000334e:	05864603          	lbu	a2,88(a2)
    80003352:	00c6f5b3          	and	a1,a3,a2
    80003356:	d585                	beqz	a1,8000327e <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003358:	2705                	addiw	a4,a4,1
    8000335a:	2485                	addiw	s1,s1,1
    8000335c:	fd471ae3          	bne	a4,s4,80003330 <balloc+0xee>
    80003360:	b769                	j	800032ea <balloc+0xa8>
    80003362:	6906                	ld	s2,64(sp)
    80003364:	79e2                	ld	s3,56(sp)
    80003366:	7a42                	ld	s4,48(sp)
    80003368:	7aa2                	ld	s5,40(sp)
    8000336a:	7b02                	ld	s6,32(sp)
    8000336c:	6be2                	ld	s7,24(sp)
    8000336e:	6c42                	ld	s8,16(sp)
    80003370:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003372:	00005517          	auipc	a0,0x5
    80003376:	0c650513          	addi	a0,a0,198 # 80008438 <etext+0x438>
    8000337a:	ffffd097          	auipc	ra,0xffffd
    8000337e:	230080e7          	jalr	560(ra) # 800005aa <printf>
  return 0;
    80003382:	4481                	li	s1,0
    80003384:	bfa9                	j	800032de <balloc+0x9c>

0000000080003386 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003386:	7179                	addi	sp,sp,-48
    80003388:	f406                	sd	ra,40(sp)
    8000338a:	f022                	sd	s0,32(sp)
    8000338c:	ec26                	sd	s1,24(sp)
    8000338e:	e84a                	sd	s2,16(sp)
    80003390:	e44e                	sd	s3,8(sp)
    80003392:	1800                	addi	s0,sp,48
    80003394:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003396:	47ad                	li	a5,11
    80003398:	02b7e863          	bltu	a5,a1,800033c8 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000339c:	02059793          	slli	a5,a1,0x20
    800033a0:	01e7d593          	srli	a1,a5,0x1e
    800033a4:	00b504b3          	add	s1,a0,a1
    800033a8:	0504a903          	lw	s2,80(s1)
    800033ac:	08091263          	bnez	s2,80003430 <bmap+0xaa>
      addr = balloc(ip->dev);
    800033b0:	4108                	lw	a0,0(a0)
    800033b2:	00000097          	auipc	ra,0x0
    800033b6:	e90080e7          	jalr	-368(ra) # 80003242 <balloc>
    800033ba:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033be:	06090963          	beqz	s2,80003430 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    800033c2:	0524a823          	sw	s2,80(s1)
    800033c6:	a0ad                	j	80003430 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033c8:	ff45849b          	addiw	s1,a1,-12
    800033cc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033d0:	0ff00793          	li	a5,255
    800033d4:	08e7e863          	bltu	a5,a4,80003464 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033d8:	08052903          	lw	s2,128(a0)
    800033dc:	00091f63          	bnez	s2,800033fa <bmap+0x74>
      addr = balloc(ip->dev);
    800033e0:	4108                	lw	a0,0(a0)
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	e60080e7          	jalr	-416(ra) # 80003242 <balloc>
    800033ea:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033ee:	04090163          	beqz	s2,80003430 <bmap+0xaa>
    800033f2:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800033f4:	0929a023          	sw	s2,128(s3)
    800033f8:	a011                	j	800033fc <bmap+0x76>
    800033fa:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800033fc:	85ca                	mv	a1,s2
    800033fe:	0009a503          	lw	a0,0(s3)
    80003402:	00000097          	auipc	ra,0x0
    80003406:	b80080e7          	jalr	-1152(ra) # 80002f82 <bread>
    8000340a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000340c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003410:	02049713          	slli	a4,s1,0x20
    80003414:	01e75593          	srli	a1,a4,0x1e
    80003418:	00b784b3          	add	s1,a5,a1
    8000341c:	0004a903          	lw	s2,0(s1)
    80003420:	02090063          	beqz	s2,80003440 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003424:	8552                	mv	a0,s4
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	c8c080e7          	jalr	-884(ra) # 800030b2 <brelse>
    return addr;
    8000342e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003430:	854a                	mv	a0,s2
    80003432:	70a2                	ld	ra,40(sp)
    80003434:	7402                	ld	s0,32(sp)
    80003436:	64e2                	ld	s1,24(sp)
    80003438:	6942                	ld	s2,16(sp)
    8000343a:	69a2                	ld	s3,8(sp)
    8000343c:	6145                	addi	sp,sp,48
    8000343e:	8082                	ret
      addr = balloc(ip->dev);
    80003440:	0009a503          	lw	a0,0(s3)
    80003444:	00000097          	auipc	ra,0x0
    80003448:	dfe080e7          	jalr	-514(ra) # 80003242 <balloc>
    8000344c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003450:	fc090ae3          	beqz	s2,80003424 <bmap+0x9e>
        a[bn] = addr;
    80003454:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003458:	8552                	mv	a0,s4
    8000345a:	00001097          	auipc	ra,0x1
    8000345e:	f02080e7          	jalr	-254(ra) # 8000435c <log_write>
    80003462:	b7c9                	j	80003424 <bmap+0x9e>
    80003464:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003466:	00005517          	auipc	a0,0x5
    8000346a:	fea50513          	addi	a0,a0,-22 # 80008450 <etext+0x450>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	0f2080e7          	jalr	242(ra) # 80000560 <panic>

0000000080003476 <iget>:
{
    80003476:	7179                	addi	sp,sp,-48
    80003478:	f406                	sd	ra,40(sp)
    8000347a:	f022                	sd	s0,32(sp)
    8000347c:	ec26                	sd	s1,24(sp)
    8000347e:	e84a                	sd	s2,16(sp)
    80003480:	e44e                	sd	s3,8(sp)
    80003482:	e052                	sd	s4,0(sp)
    80003484:	1800                	addi	s0,sp,48
    80003486:	89aa                	mv	s3,a0
    80003488:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000348a:	0001e517          	auipc	a0,0x1e
    8000348e:	6fe50513          	addi	a0,a0,1790 # 80021b88 <itable>
    80003492:	ffffd097          	auipc	ra,0xffffd
    80003496:	7a6080e7          	jalr	1958(ra) # 80000c38 <acquire>
  empty = 0;
    8000349a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000349c:	0001e497          	auipc	s1,0x1e
    800034a0:	70448493          	addi	s1,s1,1796 # 80021ba0 <itable+0x18>
    800034a4:	00020697          	auipc	a3,0x20
    800034a8:	18c68693          	addi	a3,a3,396 # 80023630 <log>
    800034ac:	a039                	j	800034ba <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034ae:	02090b63          	beqz	s2,800034e4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034b2:	08848493          	addi	s1,s1,136
    800034b6:	02d48a63          	beq	s1,a3,800034ea <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034ba:	449c                	lw	a5,8(s1)
    800034bc:	fef059e3          	blez	a5,800034ae <iget+0x38>
    800034c0:	4098                	lw	a4,0(s1)
    800034c2:	ff3716e3          	bne	a4,s3,800034ae <iget+0x38>
    800034c6:	40d8                	lw	a4,4(s1)
    800034c8:	ff4713e3          	bne	a4,s4,800034ae <iget+0x38>
      ip->ref++;
    800034cc:	2785                	addiw	a5,a5,1
    800034ce:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034d0:	0001e517          	auipc	a0,0x1e
    800034d4:	6b850513          	addi	a0,a0,1720 # 80021b88 <itable>
    800034d8:	ffffe097          	auipc	ra,0xffffe
    800034dc:	814080e7          	jalr	-2028(ra) # 80000cec <release>
      return ip;
    800034e0:	8926                	mv	s2,s1
    800034e2:	a03d                	j	80003510 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034e4:	f7f9                	bnez	a5,800034b2 <iget+0x3c>
      empty = ip;
    800034e6:	8926                	mv	s2,s1
    800034e8:	b7e9                	j	800034b2 <iget+0x3c>
  if(empty == 0)
    800034ea:	02090c63          	beqz	s2,80003522 <iget+0xac>
  ip->dev = dev;
    800034ee:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034f2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034f6:	4785                	li	a5,1
    800034f8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034fc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003500:	0001e517          	auipc	a0,0x1e
    80003504:	68850513          	addi	a0,a0,1672 # 80021b88 <itable>
    80003508:	ffffd097          	auipc	ra,0xffffd
    8000350c:	7e4080e7          	jalr	2020(ra) # 80000cec <release>
}
    80003510:	854a                	mv	a0,s2
    80003512:	70a2                	ld	ra,40(sp)
    80003514:	7402                	ld	s0,32(sp)
    80003516:	64e2                	ld	s1,24(sp)
    80003518:	6942                	ld	s2,16(sp)
    8000351a:	69a2                	ld	s3,8(sp)
    8000351c:	6a02                	ld	s4,0(sp)
    8000351e:	6145                	addi	sp,sp,48
    80003520:	8082                	ret
    panic("iget: no inodes");
    80003522:	00005517          	auipc	a0,0x5
    80003526:	f4650513          	addi	a0,a0,-186 # 80008468 <etext+0x468>
    8000352a:	ffffd097          	auipc	ra,0xffffd
    8000352e:	036080e7          	jalr	54(ra) # 80000560 <panic>

0000000080003532 <fsinit>:
fsinit(int dev) {
    80003532:	7179                	addi	sp,sp,-48
    80003534:	f406                	sd	ra,40(sp)
    80003536:	f022                	sd	s0,32(sp)
    80003538:	ec26                	sd	s1,24(sp)
    8000353a:	e84a                	sd	s2,16(sp)
    8000353c:	e44e                	sd	s3,8(sp)
    8000353e:	1800                	addi	s0,sp,48
    80003540:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003542:	4585                	li	a1,1
    80003544:	00000097          	auipc	ra,0x0
    80003548:	a3e080e7          	jalr	-1474(ra) # 80002f82 <bread>
    8000354c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000354e:	0001e997          	auipc	s3,0x1e
    80003552:	61a98993          	addi	s3,s3,1562 # 80021b68 <sb>
    80003556:	02000613          	li	a2,32
    8000355a:	05850593          	addi	a1,a0,88
    8000355e:	854e                	mv	a0,s3
    80003560:	ffffe097          	auipc	ra,0xffffe
    80003564:	830080e7          	jalr	-2000(ra) # 80000d90 <memmove>
  brelse(bp);
    80003568:	8526                	mv	a0,s1
    8000356a:	00000097          	auipc	ra,0x0
    8000356e:	b48080e7          	jalr	-1208(ra) # 800030b2 <brelse>
  if(sb.magic != FSMAGIC)
    80003572:	0009a703          	lw	a4,0(s3)
    80003576:	102037b7          	lui	a5,0x10203
    8000357a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000357e:	02f71263          	bne	a4,a5,800035a2 <fsinit+0x70>
  initlog(dev, &sb);
    80003582:	0001e597          	auipc	a1,0x1e
    80003586:	5e658593          	addi	a1,a1,1510 # 80021b68 <sb>
    8000358a:	854a                	mv	a0,s2
    8000358c:	00001097          	auipc	ra,0x1
    80003590:	b60080e7          	jalr	-1184(ra) # 800040ec <initlog>
}
    80003594:	70a2                	ld	ra,40(sp)
    80003596:	7402                	ld	s0,32(sp)
    80003598:	64e2                	ld	s1,24(sp)
    8000359a:	6942                	ld	s2,16(sp)
    8000359c:	69a2                	ld	s3,8(sp)
    8000359e:	6145                	addi	sp,sp,48
    800035a0:	8082                	ret
    panic("invalid file system");
    800035a2:	00005517          	auipc	a0,0x5
    800035a6:	ed650513          	addi	a0,a0,-298 # 80008478 <etext+0x478>
    800035aa:	ffffd097          	auipc	ra,0xffffd
    800035ae:	fb6080e7          	jalr	-74(ra) # 80000560 <panic>

00000000800035b2 <iinit>:
{
    800035b2:	7179                	addi	sp,sp,-48
    800035b4:	f406                	sd	ra,40(sp)
    800035b6:	f022                	sd	s0,32(sp)
    800035b8:	ec26                	sd	s1,24(sp)
    800035ba:	e84a                	sd	s2,16(sp)
    800035bc:	e44e                	sd	s3,8(sp)
    800035be:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800035c0:	00005597          	auipc	a1,0x5
    800035c4:	ed058593          	addi	a1,a1,-304 # 80008490 <etext+0x490>
    800035c8:	0001e517          	auipc	a0,0x1e
    800035cc:	5c050513          	addi	a0,a0,1472 # 80021b88 <itable>
    800035d0:	ffffd097          	auipc	ra,0xffffd
    800035d4:	5d8080e7          	jalr	1496(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035d8:	0001e497          	auipc	s1,0x1e
    800035dc:	5d848493          	addi	s1,s1,1496 # 80021bb0 <itable+0x28>
    800035e0:	00020997          	auipc	s3,0x20
    800035e4:	06098993          	addi	s3,s3,96 # 80023640 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035e8:	00005917          	auipc	s2,0x5
    800035ec:	eb090913          	addi	s2,s2,-336 # 80008498 <etext+0x498>
    800035f0:	85ca                	mv	a1,s2
    800035f2:	8526                	mv	a0,s1
    800035f4:	00001097          	auipc	ra,0x1
    800035f8:	e4c080e7          	jalr	-436(ra) # 80004440 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035fc:	08848493          	addi	s1,s1,136
    80003600:	ff3498e3          	bne	s1,s3,800035f0 <iinit+0x3e>
}
    80003604:	70a2                	ld	ra,40(sp)
    80003606:	7402                	ld	s0,32(sp)
    80003608:	64e2                	ld	s1,24(sp)
    8000360a:	6942                	ld	s2,16(sp)
    8000360c:	69a2                	ld	s3,8(sp)
    8000360e:	6145                	addi	sp,sp,48
    80003610:	8082                	ret

0000000080003612 <ialloc>:
{
    80003612:	7139                	addi	sp,sp,-64
    80003614:	fc06                	sd	ra,56(sp)
    80003616:	f822                	sd	s0,48(sp)
    80003618:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000361a:	0001e717          	auipc	a4,0x1e
    8000361e:	55a72703          	lw	a4,1370(a4) # 80021b74 <sb+0xc>
    80003622:	4785                	li	a5,1
    80003624:	06e7f463          	bgeu	a5,a4,8000368c <ialloc+0x7a>
    80003628:	f426                	sd	s1,40(sp)
    8000362a:	f04a                	sd	s2,32(sp)
    8000362c:	ec4e                	sd	s3,24(sp)
    8000362e:	e852                	sd	s4,16(sp)
    80003630:	e456                	sd	s5,8(sp)
    80003632:	e05a                	sd	s6,0(sp)
    80003634:	8aaa                	mv	s5,a0
    80003636:	8b2e                	mv	s6,a1
    80003638:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000363a:	0001ea17          	auipc	s4,0x1e
    8000363e:	52ea0a13          	addi	s4,s4,1326 # 80021b68 <sb>
    80003642:	00495593          	srli	a1,s2,0x4
    80003646:	018a2783          	lw	a5,24(s4)
    8000364a:	9dbd                	addw	a1,a1,a5
    8000364c:	8556                	mv	a0,s5
    8000364e:	00000097          	auipc	ra,0x0
    80003652:	934080e7          	jalr	-1740(ra) # 80002f82 <bread>
    80003656:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003658:	05850993          	addi	s3,a0,88
    8000365c:	00f97793          	andi	a5,s2,15
    80003660:	079a                	slli	a5,a5,0x6
    80003662:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003664:	00099783          	lh	a5,0(s3)
    80003668:	cf9d                	beqz	a5,800036a6 <ialloc+0x94>
    brelse(bp);
    8000366a:	00000097          	auipc	ra,0x0
    8000366e:	a48080e7          	jalr	-1464(ra) # 800030b2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003672:	0905                	addi	s2,s2,1
    80003674:	00ca2703          	lw	a4,12(s4)
    80003678:	0009079b          	sext.w	a5,s2
    8000367c:	fce7e3e3          	bltu	a5,a4,80003642 <ialloc+0x30>
    80003680:	74a2                	ld	s1,40(sp)
    80003682:	7902                	ld	s2,32(sp)
    80003684:	69e2                	ld	s3,24(sp)
    80003686:	6a42                	ld	s4,16(sp)
    80003688:	6aa2                	ld	s5,8(sp)
    8000368a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000368c:	00005517          	auipc	a0,0x5
    80003690:	e1450513          	addi	a0,a0,-492 # 800084a0 <etext+0x4a0>
    80003694:	ffffd097          	auipc	ra,0xffffd
    80003698:	f16080e7          	jalr	-234(ra) # 800005aa <printf>
  return 0;
    8000369c:	4501                	li	a0,0
}
    8000369e:	70e2                	ld	ra,56(sp)
    800036a0:	7442                	ld	s0,48(sp)
    800036a2:	6121                	addi	sp,sp,64
    800036a4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036a6:	04000613          	li	a2,64
    800036aa:	4581                	li	a1,0
    800036ac:	854e                	mv	a0,s3
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	686080e7          	jalr	1670(ra) # 80000d34 <memset>
      dip->type = type;
    800036b6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036ba:	8526                	mv	a0,s1
    800036bc:	00001097          	auipc	ra,0x1
    800036c0:	ca0080e7          	jalr	-864(ra) # 8000435c <log_write>
      brelse(bp);
    800036c4:	8526                	mv	a0,s1
    800036c6:	00000097          	auipc	ra,0x0
    800036ca:	9ec080e7          	jalr	-1556(ra) # 800030b2 <brelse>
      return iget(dev, inum);
    800036ce:	0009059b          	sext.w	a1,s2
    800036d2:	8556                	mv	a0,s5
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	da2080e7          	jalr	-606(ra) # 80003476 <iget>
    800036dc:	74a2                	ld	s1,40(sp)
    800036de:	7902                	ld	s2,32(sp)
    800036e0:	69e2                	ld	s3,24(sp)
    800036e2:	6a42                	ld	s4,16(sp)
    800036e4:	6aa2                	ld	s5,8(sp)
    800036e6:	6b02                	ld	s6,0(sp)
    800036e8:	bf5d                	j	8000369e <ialloc+0x8c>

00000000800036ea <iupdate>:
{
    800036ea:	1101                	addi	sp,sp,-32
    800036ec:	ec06                	sd	ra,24(sp)
    800036ee:	e822                	sd	s0,16(sp)
    800036f0:	e426                	sd	s1,8(sp)
    800036f2:	e04a                	sd	s2,0(sp)
    800036f4:	1000                	addi	s0,sp,32
    800036f6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036f8:	415c                	lw	a5,4(a0)
    800036fa:	0047d79b          	srliw	a5,a5,0x4
    800036fe:	0001e597          	auipc	a1,0x1e
    80003702:	4825a583          	lw	a1,1154(a1) # 80021b80 <sb+0x18>
    80003706:	9dbd                	addw	a1,a1,a5
    80003708:	4108                	lw	a0,0(a0)
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	878080e7          	jalr	-1928(ra) # 80002f82 <bread>
    80003712:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003714:	05850793          	addi	a5,a0,88
    80003718:	40d8                	lw	a4,4(s1)
    8000371a:	8b3d                	andi	a4,a4,15
    8000371c:	071a                	slli	a4,a4,0x6
    8000371e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003720:	04449703          	lh	a4,68(s1)
    80003724:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003728:	04649703          	lh	a4,70(s1)
    8000372c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003730:	04849703          	lh	a4,72(s1)
    80003734:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003738:	04a49703          	lh	a4,74(s1)
    8000373c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003740:	44f8                	lw	a4,76(s1)
    80003742:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003744:	03400613          	li	a2,52
    80003748:	05048593          	addi	a1,s1,80
    8000374c:	00c78513          	addi	a0,a5,12
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	640080e7          	jalr	1600(ra) # 80000d90 <memmove>
  log_write(bp);
    80003758:	854a                	mv	a0,s2
    8000375a:	00001097          	auipc	ra,0x1
    8000375e:	c02080e7          	jalr	-1022(ra) # 8000435c <log_write>
  brelse(bp);
    80003762:	854a                	mv	a0,s2
    80003764:	00000097          	auipc	ra,0x0
    80003768:	94e080e7          	jalr	-1714(ra) # 800030b2 <brelse>
}
    8000376c:	60e2                	ld	ra,24(sp)
    8000376e:	6442                	ld	s0,16(sp)
    80003770:	64a2                	ld	s1,8(sp)
    80003772:	6902                	ld	s2,0(sp)
    80003774:	6105                	addi	sp,sp,32
    80003776:	8082                	ret

0000000080003778 <idup>:
{
    80003778:	1101                	addi	sp,sp,-32
    8000377a:	ec06                	sd	ra,24(sp)
    8000377c:	e822                	sd	s0,16(sp)
    8000377e:	e426                	sd	s1,8(sp)
    80003780:	1000                	addi	s0,sp,32
    80003782:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003784:	0001e517          	auipc	a0,0x1e
    80003788:	40450513          	addi	a0,a0,1028 # 80021b88 <itable>
    8000378c:	ffffd097          	auipc	ra,0xffffd
    80003790:	4ac080e7          	jalr	1196(ra) # 80000c38 <acquire>
  ip->ref++;
    80003794:	449c                	lw	a5,8(s1)
    80003796:	2785                	addiw	a5,a5,1
    80003798:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000379a:	0001e517          	auipc	a0,0x1e
    8000379e:	3ee50513          	addi	a0,a0,1006 # 80021b88 <itable>
    800037a2:	ffffd097          	auipc	ra,0xffffd
    800037a6:	54a080e7          	jalr	1354(ra) # 80000cec <release>
}
    800037aa:	8526                	mv	a0,s1
    800037ac:	60e2                	ld	ra,24(sp)
    800037ae:	6442                	ld	s0,16(sp)
    800037b0:	64a2                	ld	s1,8(sp)
    800037b2:	6105                	addi	sp,sp,32
    800037b4:	8082                	ret

00000000800037b6 <ilock>:
{
    800037b6:	1101                	addi	sp,sp,-32
    800037b8:	ec06                	sd	ra,24(sp)
    800037ba:	e822                	sd	s0,16(sp)
    800037bc:	e426                	sd	s1,8(sp)
    800037be:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037c0:	c10d                	beqz	a0,800037e2 <ilock+0x2c>
    800037c2:	84aa                	mv	s1,a0
    800037c4:	451c                	lw	a5,8(a0)
    800037c6:	00f05e63          	blez	a5,800037e2 <ilock+0x2c>
  acquiresleep(&ip->lock);
    800037ca:	0541                	addi	a0,a0,16
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	cae080e7          	jalr	-850(ra) # 8000447a <acquiresleep>
  if(ip->valid == 0){
    800037d4:	40bc                	lw	a5,64(s1)
    800037d6:	cf99                	beqz	a5,800037f4 <ilock+0x3e>
}
    800037d8:	60e2                	ld	ra,24(sp)
    800037da:	6442                	ld	s0,16(sp)
    800037dc:	64a2                	ld	s1,8(sp)
    800037de:	6105                	addi	sp,sp,32
    800037e0:	8082                	ret
    800037e2:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800037e4:	00005517          	auipc	a0,0x5
    800037e8:	cd450513          	addi	a0,a0,-812 # 800084b8 <etext+0x4b8>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	d74080e7          	jalr	-652(ra) # 80000560 <panic>
    800037f4:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037f6:	40dc                	lw	a5,4(s1)
    800037f8:	0047d79b          	srliw	a5,a5,0x4
    800037fc:	0001e597          	auipc	a1,0x1e
    80003800:	3845a583          	lw	a1,900(a1) # 80021b80 <sb+0x18>
    80003804:	9dbd                	addw	a1,a1,a5
    80003806:	4088                	lw	a0,0(s1)
    80003808:	fffff097          	auipc	ra,0xfffff
    8000380c:	77a080e7          	jalr	1914(ra) # 80002f82 <bread>
    80003810:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003812:	05850593          	addi	a1,a0,88
    80003816:	40dc                	lw	a5,4(s1)
    80003818:	8bbd                	andi	a5,a5,15
    8000381a:	079a                	slli	a5,a5,0x6
    8000381c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000381e:	00059783          	lh	a5,0(a1)
    80003822:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003826:	00259783          	lh	a5,2(a1)
    8000382a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000382e:	00459783          	lh	a5,4(a1)
    80003832:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003836:	00659783          	lh	a5,6(a1)
    8000383a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000383e:	459c                	lw	a5,8(a1)
    80003840:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003842:	03400613          	li	a2,52
    80003846:	05b1                	addi	a1,a1,12
    80003848:	05048513          	addi	a0,s1,80
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	544080e7          	jalr	1348(ra) # 80000d90 <memmove>
    brelse(bp);
    80003854:	854a                	mv	a0,s2
    80003856:	00000097          	auipc	ra,0x0
    8000385a:	85c080e7          	jalr	-1956(ra) # 800030b2 <brelse>
    ip->valid = 1;
    8000385e:	4785                	li	a5,1
    80003860:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003862:	04449783          	lh	a5,68(s1)
    80003866:	c399                	beqz	a5,8000386c <ilock+0xb6>
    80003868:	6902                	ld	s2,0(sp)
    8000386a:	b7bd                	j	800037d8 <ilock+0x22>
      panic("ilock: no type");
    8000386c:	00005517          	auipc	a0,0x5
    80003870:	c5450513          	addi	a0,a0,-940 # 800084c0 <etext+0x4c0>
    80003874:	ffffd097          	auipc	ra,0xffffd
    80003878:	cec080e7          	jalr	-788(ra) # 80000560 <panic>

000000008000387c <iunlock>:
{
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	e426                	sd	s1,8(sp)
    80003884:	e04a                	sd	s2,0(sp)
    80003886:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003888:	c905                	beqz	a0,800038b8 <iunlock+0x3c>
    8000388a:	84aa                	mv	s1,a0
    8000388c:	01050913          	addi	s2,a0,16
    80003890:	854a                	mv	a0,s2
    80003892:	00001097          	auipc	ra,0x1
    80003896:	c82080e7          	jalr	-894(ra) # 80004514 <holdingsleep>
    8000389a:	cd19                	beqz	a0,800038b8 <iunlock+0x3c>
    8000389c:	449c                	lw	a5,8(s1)
    8000389e:	00f05d63          	blez	a5,800038b8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038a2:	854a                	mv	a0,s2
    800038a4:	00001097          	auipc	ra,0x1
    800038a8:	c2c080e7          	jalr	-980(ra) # 800044d0 <releasesleep>
}
    800038ac:	60e2                	ld	ra,24(sp)
    800038ae:	6442                	ld	s0,16(sp)
    800038b0:	64a2                	ld	s1,8(sp)
    800038b2:	6902                	ld	s2,0(sp)
    800038b4:	6105                	addi	sp,sp,32
    800038b6:	8082                	ret
    panic("iunlock");
    800038b8:	00005517          	auipc	a0,0x5
    800038bc:	c1850513          	addi	a0,a0,-1000 # 800084d0 <etext+0x4d0>
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	ca0080e7          	jalr	-864(ra) # 80000560 <panic>

00000000800038c8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038c8:	7179                	addi	sp,sp,-48
    800038ca:	f406                	sd	ra,40(sp)
    800038cc:	f022                	sd	s0,32(sp)
    800038ce:	ec26                	sd	s1,24(sp)
    800038d0:	e84a                	sd	s2,16(sp)
    800038d2:	e44e                	sd	s3,8(sp)
    800038d4:	1800                	addi	s0,sp,48
    800038d6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038d8:	05050493          	addi	s1,a0,80
    800038dc:	08050913          	addi	s2,a0,128
    800038e0:	a021                	j	800038e8 <itrunc+0x20>
    800038e2:	0491                	addi	s1,s1,4
    800038e4:	01248d63          	beq	s1,s2,800038fe <itrunc+0x36>
    if(ip->addrs[i]){
    800038e8:	408c                	lw	a1,0(s1)
    800038ea:	dde5                	beqz	a1,800038e2 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800038ec:	0009a503          	lw	a0,0(s3)
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	8d6080e7          	jalr	-1834(ra) # 800031c6 <bfree>
      ip->addrs[i] = 0;
    800038f8:	0004a023          	sw	zero,0(s1)
    800038fc:	b7dd                	j	800038e2 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038fe:	0809a583          	lw	a1,128(s3)
    80003902:	ed99                	bnez	a1,80003920 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003904:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003908:	854e                	mv	a0,s3
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	de0080e7          	jalr	-544(ra) # 800036ea <iupdate>
}
    80003912:	70a2                	ld	ra,40(sp)
    80003914:	7402                	ld	s0,32(sp)
    80003916:	64e2                	ld	s1,24(sp)
    80003918:	6942                	ld	s2,16(sp)
    8000391a:	69a2                	ld	s3,8(sp)
    8000391c:	6145                	addi	sp,sp,48
    8000391e:	8082                	ret
    80003920:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003922:	0009a503          	lw	a0,0(s3)
    80003926:	fffff097          	auipc	ra,0xfffff
    8000392a:	65c080e7          	jalr	1628(ra) # 80002f82 <bread>
    8000392e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003930:	05850493          	addi	s1,a0,88
    80003934:	45850913          	addi	s2,a0,1112
    80003938:	a021                	j	80003940 <itrunc+0x78>
    8000393a:	0491                	addi	s1,s1,4
    8000393c:	01248b63          	beq	s1,s2,80003952 <itrunc+0x8a>
      if(a[j])
    80003940:	408c                	lw	a1,0(s1)
    80003942:	dde5                	beqz	a1,8000393a <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003944:	0009a503          	lw	a0,0(s3)
    80003948:	00000097          	auipc	ra,0x0
    8000394c:	87e080e7          	jalr	-1922(ra) # 800031c6 <bfree>
    80003950:	b7ed                	j	8000393a <itrunc+0x72>
    brelse(bp);
    80003952:	8552                	mv	a0,s4
    80003954:	fffff097          	auipc	ra,0xfffff
    80003958:	75e080e7          	jalr	1886(ra) # 800030b2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000395c:	0809a583          	lw	a1,128(s3)
    80003960:	0009a503          	lw	a0,0(s3)
    80003964:	00000097          	auipc	ra,0x0
    80003968:	862080e7          	jalr	-1950(ra) # 800031c6 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000396c:	0809a023          	sw	zero,128(s3)
    80003970:	6a02                	ld	s4,0(sp)
    80003972:	bf49                	j	80003904 <itrunc+0x3c>

0000000080003974 <iput>:
{
    80003974:	1101                	addi	sp,sp,-32
    80003976:	ec06                	sd	ra,24(sp)
    80003978:	e822                	sd	s0,16(sp)
    8000397a:	e426                	sd	s1,8(sp)
    8000397c:	1000                	addi	s0,sp,32
    8000397e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003980:	0001e517          	auipc	a0,0x1e
    80003984:	20850513          	addi	a0,a0,520 # 80021b88 <itable>
    80003988:	ffffd097          	auipc	ra,0xffffd
    8000398c:	2b0080e7          	jalr	688(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003990:	4498                	lw	a4,8(s1)
    80003992:	4785                	li	a5,1
    80003994:	02f70263          	beq	a4,a5,800039b8 <iput+0x44>
  ip->ref--;
    80003998:	449c                	lw	a5,8(s1)
    8000399a:	37fd                	addiw	a5,a5,-1
    8000399c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000399e:	0001e517          	auipc	a0,0x1e
    800039a2:	1ea50513          	addi	a0,a0,490 # 80021b88 <itable>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	346080e7          	jalr	838(ra) # 80000cec <release>
}
    800039ae:	60e2                	ld	ra,24(sp)
    800039b0:	6442                	ld	s0,16(sp)
    800039b2:	64a2                	ld	s1,8(sp)
    800039b4:	6105                	addi	sp,sp,32
    800039b6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039b8:	40bc                	lw	a5,64(s1)
    800039ba:	dff9                	beqz	a5,80003998 <iput+0x24>
    800039bc:	04a49783          	lh	a5,74(s1)
    800039c0:	ffe1                	bnez	a5,80003998 <iput+0x24>
    800039c2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800039c4:	01048913          	addi	s2,s1,16
    800039c8:	854a                	mv	a0,s2
    800039ca:	00001097          	auipc	ra,0x1
    800039ce:	ab0080e7          	jalr	-1360(ra) # 8000447a <acquiresleep>
    release(&itable.lock);
    800039d2:	0001e517          	auipc	a0,0x1e
    800039d6:	1b650513          	addi	a0,a0,438 # 80021b88 <itable>
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	312080e7          	jalr	786(ra) # 80000cec <release>
    itrunc(ip);
    800039e2:	8526                	mv	a0,s1
    800039e4:	00000097          	auipc	ra,0x0
    800039e8:	ee4080e7          	jalr	-284(ra) # 800038c8 <itrunc>
    ip->type = 0;
    800039ec:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039f0:	8526                	mv	a0,s1
    800039f2:	00000097          	auipc	ra,0x0
    800039f6:	cf8080e7          	jalr	-776(ra) # 800036ea <iupdate>
    ip->valid = 0;
    800039fa:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039fe:	854a                	mv	a0,s2
    80003a00:	00001097          	auipc	ra,0x1
    80003a04:	ad0080e7          	jalr	-1328(ra) # 800044d0 <releasesleep>
    acquire(&itable.lock);
    80003a08:	0001e517          	auipc	a0,0x1e
    80003a0c:	18050513          	addi	a0,a0,384 # 80021b88 <itable>
    80003a10:	ffffd097          	auipc	ra,0xffffd
    80003a14:	228080e7          	jalr	552(ra) # 80000c38 <acquire>
    80003a18:	6902                	ld	s2,0(sp)
    80003a1a:	bfbd                	j	80003998 <iput+0x24>

0000000080003a1c <iunlockput>:
{
    80003a1c:	1101                	addi	sp,sp,-32
    80003a1e:	ec06                	sd	ra,24(sp)
    80003a20:	e822                	sd	s0,16(sp)
    80003a22:	e426                	sd	s1,8(sp)
    80003a24:	1000                	addi	s0,sp,32
    80003a26:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	e54080e7          	jalr	-428(ra) # 8000387c <iunlock>
  iput(ip);
    80003a30:	8526                	mv	a0,s1
    80003a32:	00000097          	auipc	ra,0x0
    80003a36:	f42080e7          	jalr	-190(ra) # 80003974 <iput>
}
    80003a3a:	60e2                	ld	ra,24(sp)
    80003a3c:	6442                	ld	s0,16(sp)
    80003a3e:	64a2                	ld	s1,8(sp)
    80003a40:	6105                	addi	sp,sp,32
    80003a42:	8082                	ret

0000000080003a44 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a44:	1141                	addi	sp,sp,-16
    80003a46:	e422                	sd	s0,8(sp)
    80003a48:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a4a:	411c                	lw	a5,0(a0)
    80003a4c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a4e:	415c                	lw	a5,4(a0)
    80003a50:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a52:	04451783          	lh	a5,68(a0)
    80003a56:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a5a:	04a51783          	lh	a5,74(a0)
    80003a5e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a62:	04c56783          	lwu	a5,76(a0)
    80003a66:	e99c                	sd	a5,16(a1)
}
    80003a68:	6422                	ld	s0,8(sp)
    80003a6a:	0141                	addi	sp,sp,16
    80003a6c:	8082                	ret

0000000080003a6e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a6e:	457c                	lw	a5,76(a0)
    80003a70:	10d7e563          	bltu	a5,a3,80003b7a <readi+0x10c>
{
    80003a74:	7159                	addi	sp,sp,-112
    80003a76:	f486                	sd	ra,104(sp)
    80003a78:	f0a2                	sd	s0,96(sp)
    80003a7a:	eca6                	sd	s1,88(sp)
    80003a7c:	e0d2                	sd	s4,64(sp)
    80003a7e:	fc56                	sd	s5,56(sp)
    80003a80:	f85a                	sd	s6,48(sp)
    80003a82:	f45e                	sd	s7,40(sp)
    80003a84:	1880                	addi	s0,sp,112
    80003a86:	8b2a                	mv	s6,a0
    80003a88:	8bae                	mv	s7,a1
    80003a8a:	8a32                	mv	s4,a2
    80003a8c:	84b6                	mv	s1,a3
    80003a8e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a90:	9f35                	addw	a4,a4,a3
    return 0;
    80003a92:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a94:	0cd76a63          	bltu	a4,a3,80003b68 <readi+0xfa>
    80003a98:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003a9a:	00e7f463          	bgeu	a5,a4,80003aa2 <readi+0x34>
    n = ip->size - off;
    80003a9e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aa2:	0a0a8963          	beqz	s5,80003b54 <readi+0xe6>
    80003aa6:	e8ca                	sd	s2,80(sp)
    80003aa8:	f062                	sd	s8,32(sp)
    80003aaa:	ec66                	sd	s9,24(sp)
    80003aac:	e86a                	sd	s10,16(sp)
    80003aae:	e46e                	sd	s11,8(sp)
    80003ab0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ab2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ab6:	5c7d                	li	s8,-1
    80003ab8:	a82d                	j	80003af2 <readi+0x84>
    80003aba:	020d1d93          	slli	s11,s10,0x20
    80003abe:	020ddd93          	srli	s11,s11,0x20
    80003ac2:	05890613          	addi	a2,s2,88
    80003ac6:	86ee                	mv	a3,s11
    80003ac8:	963a                	add	a2,a2,a4
    80003aca:	85d2                	mv	a1,s4
    80003acc:	855e                	mv	a0,s7
    80003ace:	fffff097          	auipc	ra,0xfffff
    80003ad2:	a36080e7          	jalr	-1482(ra) # 80002504 <either_copyout>
    80003ad6:	05850d63          	beq	a0,s8,80003b30 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ada:	854a                	mv	a0,s2
    80003adc:	fffff097          	auipc	ra,0xfffff
    80003ae0:	5d6080e7          	jalr	1494(ra) # 800030b2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae4:	013d09bb          	addw	s3,s10,s3
    80003ae8:	009d04bb          	addw	s1,s10,s1
    80003aec:	9a6e                	add	s4,s4,s11
    80003aee:	0559fd63          	bgeu	s3,s5,80003b48 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003af2:	00a4d59b          	srliw	a1,s1,0xa
    80003af6:	855a                	mv	a0,s6
    80003af8:	00000097          	auipc	ra,0x0
    80003afc:	88e080e7          	jalr	-1906(ra) # 80003386 <bmap>
    80003b00:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b04:	c9b1                	beqz	a1,80003b58 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003b06:	000b2503          	lw	a0,0(s6)
    80003b0a:	fffff097          	auipc	ra,0xfffff
    80003b0e:	478080e7          	jalr	1144(ra) # 80002f82 <bread>
    80003b12:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b14:	3ff4f713          	andi	a4,s1,1023
    80003b18:	40ec87bb          	subw	a5,s9,a4
    80003b1c:	413a86bb          	subw	a3,s5,s3
    80003b20:	8d3e                	mv	s10,a5
    80003b22:	2781                	sext.w	a5,a5
    80003b24:	0006861b          	sext.w	a2,a3
    80003b28:	f8f679e3          	bgeu	a2,a5,80003aba <readi+0x4c>
    80003b2c:	8d36                	mv	s10,a3
    80003b2e:	b771                	j	80003aba <readi+0x4c>
      brelse(bp);
    80003b30:	854a                	mv	a0,s2
    80003b32:	fffff097          	auipc	ra,0xfffff
    80003b36:	580080e7          	jalr	1408(ra) # 800030b2 <brelse>
      tot = -1;
    80003b3a:	59fd                	li	s3,-1
      break;
    80003b3c:	6946                	ld	s2,80(sp)
    80003b3e:	7c02                	ld	s8,32(sp)
    80003b40:	6ce2                	ld	s9,24(sp)
    80003b42:	6d42                	ld	s10,16(sp)
    80003b44:	6da2                	ld	s11,8(sp)
    80003b46:	a831                	j	80003b62 <readi+0xf4>
    80003b48:	6946                	ld	s2,80(sp)
    80003b4a:	7c02                	ld	s8,32(sp)
    80003b4c:	6ce2                	ld	s9,24(sp)
    80003b4e:	6d42                	ld	s10,16(sp)
    80003b50:	6da2                	ld	s11,8(sp)
    80003b52:	a801                	j	80003b62 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b54:	89d6                	mv	s3,s5
    80003b56:	a031                	j	80003b62 <readi+0xf4>
    80003b58:	6946                	ld	s2,80(sp)
    80003b5a:	7c02                	ld	s8,32(sp)
    80003b5c:	6ce2                	ld	s9,24(sp)
    80003b5e:	6d42                	ld	s10,16(sp)
    80003b60:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003b62:	0009851b          	sext.w	a0,s3
    80003b66:	69a6                	ld	s3,72(sp)
}
    80003b68:	70a6                	ld	ra,104(sp)
    80003b6a:	7406                	ld	s0,96(sp)
    80003b6c:	64e6                	ld	s1,88(sp)
    80003b6e:	6a06                	ld	s4,64(sp)
    80003b70:	7ae2                	ld	s5,56(sp)
    80003b72:	7b42                	ld	s6,48(sp)
    80003b74:	7ba2                	ld	s7,40(sp)
    80003b76:	6165                	addi	sp,sp,112
    80003b78:	8082                	ret
    return 0;
    80003b7a:	4501                	li	a0,0
}
    80003b7c:	8082                	ret

0000000080003b7e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b7e:	457c                	lw	a5,76(a0)
    80003b80:	10d7ee63          	bltu	a5,a3,80003c9c <writei+0x11e>
{
    80003b84:	7159                	addi	sp,sp,-112
    80003b86:	f486                	sd	ra,104(sp)
    80003b88:	f0a2                	sd	s0,96(sp)
    80003b8a:	e8ca                	sd	s2,80(sp)
    80003b8c:	e0d2                	sd	s4,64(sp)
    80003b8e:	fc56                	sd	s5,56(sp)
    80003b90:	f85a                	sd	s6,48(sp)
    80003b92:	f45e                	sd	s7,40(sp)
    80003b94:	1880                	addi	s0,sp,112
    80003b96:	8aaa                	mv	s5,a0
    80003b98:	8bae                	mv	s7,a1
    80003b9a:	8a32                	mv	s4,a2
    80003b9c:	8936                	mv	s2,a3
    80003b9e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ba0:	00e687bb          	addw	a5,a3,a4
    80003ba4:	0ed7ee63          	bltu	a5,a3,80003ca0 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ba8:	00043737          	lui	a4,0x43
    80003bac:	0ef76c63          	bltu	a4,a5,80003ca4 <writei+0x126>
    80003bb0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bb2:	0c0b0d63          	beqz	s6,80003c8c <writei+0x10e>
    80003bb6:	eca6                	sd	s1,88(sp)
    80003bb8:	f062                	sd	s8,32(sp)
    80003bba:	ec66                	sd	s9,24(sp)
    80003bbc:	e86a                	sd	s10,16(sp)
    80003bbe:	e46e                	sd	s11,8(sp)
    80003bc0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bc2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003bc6:	5c7d                	li	s8,-1
    80003bc8:	a091                	j	80003c0c <writei+0x8e>
    80003bca:	020d1d93          	slli	s11,s10,0x20
    80003bce:	020ddd93          	srli	s11,s11,0x20
    80003bd2:	05848513          	addi	a0,s1,88
    80003bd6:	86ee                	mv	a3,s11
    80003bd8:	8652                	mv	a2,s4
    80003bda:	85de                	mv	a1,s7
    80003bdc:	953a                	add	a0,a0,a4
    80003bde:	fffff097          	auipc	ra,0xfffff
    80003be2:	97c080e7          	jalr	-1668(ra) # 8000255a <either_copyin>
    80003be6:	07850263          	beq	a0,s8,80003c4a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bea:	8526                	mv	a0,s1
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	770080e7          	jalr	1904(ra) # 8000435c <log_write>
    brelse(bp);
    80003bf4:	8526                	mv	a0,s1
    80003bf6:	fffff097          	auipc	ra,0xfffff
    80003bfa:	4bc080e7          	jalr	1212(ra) # 800030b2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bfe:	013d09bb          	addw	s3,s10,s3
    80003c02:	012d093b          	addw	s2,s10,s2
    80003c06:	9a6e                	add	s4,s4,s11
    80003c08:	0569f663          	bgeu	s3,s6,80003c54 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003c0c:	00a9559b          	srliw	a1,s2,0xa
    80003c10:	8556                	mv	a0,s5
    80003c12:	fffff097          	auipc	ra,0xfffff
    80003c16:	774080e7          	jalr	1908(ra) # 80003386 <bmap>
    80003c1a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c1e:	c99d                	beqz	a1,80003c54 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003c20:	000aa503          	lw	a0,0(s5)
    80003c24:	fffff097          	auipc	ra,0xfffff
    80003c28:	35e080e7          	jalr	862(ra) # 80002f82 <bread>
    80003c2c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c2e:	3ff97713          	andi	a4,s2,1023
    80003c32:	40ec87bb          	subw	a5,s9,a4
    80003c36:	413b06bb          	subw	a3,s6,s3
    80003c3a:	8d3e                	mv	s10,a5
    80003c3c:	2781                	sext.w	a5,a5
    80003c3e:	0006861b          	sext.w	a2,a3
    80003c42:	f8f674e3          	bgeu	a2,a5,80003bca <writei+0x4c>
    80003c46:	8d36                	mv	s10,a3
    80003c48:	b749                	j	80003bca <writei+0x4c>
      brelse(bp);
    80003c4a:	8526                	mv	a0,s1
    80003c4c:	fffff097          	auipc	ra,0xfffff
    80003c50:	466080e7          	jalr	1126(ra) # 800030b2 <brelse>
  }

  if(off > ip->size)
    80003c54:	04caa783          	lw	a5,76(s5)
    80003c58:	0327fc63          	bgeu	a5,s2,80003c90 <writei+0x112>
    ip->size = off;
    80003c5c:	052aa623          	sw	s2,76(s5)
    80003c60:	64e6                	ld	s1,88(sp)
    80003c62:	7c02                	ld	s8,32(sp)
    80003c64:	6ce2                	ld	s9,24(sp)
    80003c66:	6d42                	ld	s10,16(sp)
    80003c68:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c6a:	8556                	mv	a0,s5
    80003c6c:	00000097          	auipc	ra,0x0
    80003c70:	a7e080e7          	jalr	-1410(ra) # 800036ea <iupdate>

  return tot;
    80003c74:	0009851b          	sext.w	a0,s3
    80003c78:	69a6                	ld	s3,72(sp)
}
    80003c7a:	70a6                	ld	ra,104(sp)
    80003c7c:	7406                	ld	s0,96(sp)
    80003c7e:	6946                	ld	s2,80(sp)
    80003c80:	6a06                	ld	s4,64(sp)
    80003c82:	7ae2                	ld	s5,56(sp)
    80003c84:	7b42                	ld	s6,48(sp)
    80003c86:	7ba2                	ld	s7,40(sp)
    80003c88:	6165                	addi	sp,sp,112
    80003c8a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c8c:	89da                	mv	s3,s6
    80003c8e:	bff1                	j	80003c6a <writei+0xec>
    80003c90:	64e6                	ld	s1,88(sp)
    80003c92:	7c02                	ld	s8,32(sp)
    80003c94:	6ce2                	ld	s9,24(sp)
    80003c96:	6d42                	ld	s10,16(sp)
    80003c98:	6da2                	ld	s11,8(sp)
    80003c9a:	bfc1                	j	80003c6a <writei+0xec>
    return -1;
    80003c9c:	557d                	li	a0,-1
}
    80003c9e:	8082                	ret
    return -1;
    80003ca0:	557d                	li	a0,-1
    80003ca2:	bfe1                	j	80003c7a <writei+0xfc>
    return -1;
    80003ca4:	557d                	li	a0,-1
    80003ca6:	bfd1                	j	80003c7a <writei+0xfc>

0000000080003ca8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ca8:	1141                	addi	sp,sp,-16
    80003caa:	e406                	sd	ra,8(sp)
    80003cac:	e022                	sd	s0,0(sp)
    80003cae:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003cb0:	4639                	li	a2,14
    80003cb2:	ffffd097          	auipc	ra,0xffffd
    80003cb6:	152080e7          	jalr	338(ra) # 80000e04 <strncmp>
}
    80003cba:	60a2                	ld	ra,8(sp)
    80003cbc:	6402                	ld	s0,0(sp)
    80003cbe:	0141                	addi	sp,sp,16
    80003cc0:	8082                	ret

0000000080003cc2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cc2:	7139                	addi	sp,sp,-64
    80003cc4:	fc06                	sd	ra,56(sp)
    80003cc6:	f822                	sd	s0,48(sp)
    80003cc8:	f426                	sd	s1,40(sp)
    80003cca:	f04a                	sd	s2,32(sp)
    80003ccc:	ec4e                	sd	s3,24(sp)
    80003cce:	e852                	sd	s4,16(sp)
    80003cd0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003cd2:	04451703          	lh	a4,68(a0)
    80003cd6:	4785                	li	a5,1
    80003cd8:	00f71a63          	bne	a4,a5,80003cec <dirlookup+0x2a>
    80003cdc:	892a                	mv	s2,a0
    80003cde:	89ae                	mv	s3,a1
    80003ce0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ce2:	457c                	lw	a5,76(a0)
    80003ce4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ce6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ce8:	e79d                	bnez	a5,80003d16 <dirlookup+0x54>
    80003cea:	a8a5                	j	80003d62 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003cec:	00004517          	auipc	a0,0x4
    80003cf0:	7ec50513          	addi	a0,a0,2028 # 800084d8 <etext+0x4d8>
    80003cf4:	ffffd097          	auipc	ra,0xffffd
    80003cf8:	86c080e7          	jalr	-1940(ra) # 80000560 <panic>
      panic("dirlookup read");
    80003cfc:	00004517          	auipc	a0,0x4
    80003d00:	7f450513          	addi	a0,a0,2036 # 800084f0 <etext+0x4f0>
    80003d04:	ffffd097          	auipc	ra,0xffffd
    80003d08:	85c080e7          	jalr	-1956(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d0c:	24c1                	addiw	s1,s1,16
    80003d0e:	04c92783          	lw	a5,76(s2)
    80003d12:	04f4f763          	bgeu	s1,a5,80003d60 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d16:	4741                	li	a4,16
    80003d18:	86a6                	mv	a3,s1
    80003d1a:	fc040613          	addi	a2,s0,-64
    80003d1e:	4581                	li	a1,0
    80003d20:	854a                	mv	a0,s2
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	d4c080e7          	jalr	-692(ra) # 80003a6e <readi>
    80003d2a:	47c1                	li	a5,16
    80003d2c:	fcf518e3          	bne	a0,a5,80003cfc <dirlookup+0x3a>
    if(de.inum == 0)
    80003d30:	fc045783          	lhu	a5,-64(s0)
    80003d34:	dfe1                	beqz	a5,80003d0c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d36:	fc240593          	addi	a1,s0,-62
    80003d3a:	854e                	mv	a0,s3
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	f6c080e7          	jalr	-148(ra) # 80003ca8 <namecmp>
    80003d44:	f561                	bnez	a0,80003d0c <dirlookup+0x4a>
      if(poff)
    80003d46:	000a0463          	beqz	s4,80003d4e <dirlookup+0x8c>
        *poff = off;
    80003d4a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d4e:	fc045583          	lhu	a1,-64(s0)
    80003d52:	00092503          	lw	a0,0(s2)
    80003d56:	fffff097          	auipc	ra,0xfffff
    80003d5a:	720080e7          	jalr	1824(ra) # 80003476 <iget>
    80003d5e:	a011                	j	80003d62 <dirlookup+0xa0>
  return 0;
    80003d60:	4501                	li	a0,0
}
    80003d62:	70e2                	ld	ra,56(sp)
    80003d64:	7442                	ld	s0,48(sp)
    80003d66:	74a2                	ld	s1,40(sp)
    80003d68:	7902                	ld	s2,32(sp)
    80003d6a:	69e2                	ld	s3,24(sp)
    80003d6c:	6a42                	ld	s4,16(sp)
    80003d6e:	6121                	addi	sp,sp,64
    80003d70:	8082                	ret

0000000080003d72 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d72:	711d                	addi	sp,sp,-96
    80003d74:	ec86                	sd	ra,88(sp)
    80003d76:	e8a2                	sd	s0,80(sp)
    80003d78:	e4a6                	sd	s1,72(sp)
    80003d7a:	e0ca                	sd	s2,64(sp)
    80003d7c:	fc4e                	sd	s3,56(sp)
    80003d7e:	f852                	sd	s4,48(sp)
    80003d80:	f456                	sd	s5,40(sp)
    80003d82:	f05a                	sd	s6,32(sp)
    80003d84:	ec5e                	sd	s7,24(sp)
    80003d86:	e862                	sd	s8,16(sp)
    80003d88:	e466                	sd	s9,8(sp)
    80003d8a:	1080                	addi	s0,sp,96
    80003d8c:	84aa                	mv	s1,a0
    80003d8e:	8b2e                	mv	s6,a1
    80003d90:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d92:	00054703          	lbu	a4,0(a0)
    80003d96:	02f00793          	li	a5,47
    80003d9a:	02f70263          	beq	a4,a5,80003dbe <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d9e:	ffffe097          	auipc	ra,0xffffe
    80003da2:	cb4080e7          	jalr	-844(ra) # 80001a52 <myproc>
    80003da6:	15053503          	ld	a0,336(a0)
    80003daa:	00000097          	auipc	ra,0x0
    80003dae:	9ce080e7          	jalr	-1586(ra) # 80003778 <idup>
    80003db2:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003db4:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003db8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003dba:	4b85                	li	s7,1
    80003dbc:	a875                	j	80003e78 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003dbe:	4585                	li	a1,1
    80003dc0:	4505                	li	a0,1
    80003dc2:	fffff097          	auipc	ra,0xfffff
    80003dc6:	6b4080e7          	jalr	1716(ra) # 80003476 <iget>
    80003dca:	8a2a                	mv	s4,a0
    80003dcc:	b7e5                	j	80003db4 <namex+0x42>
      iunlockput(ip);
    80003dce:	8552                	mv	a0,s4
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	c4c080e7          	jalr	-948(ra) # 80003a1c <iunlockput>
      return 0;
    80003dd8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003dda:	8552                	mv	a0,s4
    80003ddc:	60e6                	ld	ra,88(sp)
    80003dde:	6446                	ld	s0,80(sp)
    80003de0:	64a6                	ld	s1,72(sp)
    80003de2:	6906                	ld	s2,64(sp)
    80003de4:	79e2                	ld	s3,56(sp)
    80003de6:	7a42                	ld	s4,48(sp)
    80003de8:	7aa2                	ld	s5,40(sp)
    80003dea:	7b02                	ld	s6,32(sp)
    80003dec:	6be2                	ld	s7,24(sp)
    80003dee:	6c42                	ld	s8,16(sp)
    80003df0:	6ca2                	ld	s9,8(sp)
    80003df2:	6125                	addi	sp,sp,96
    80003df4:	8082                	ret
      iunlock(ip);
    80003df6:	8552                	mv	a0,s4
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	a84080e7          	jalr	-1404(ra) # 8000387c <iunlock>
      return ip;
    80003e00:	bfe9                	j	80003dda <namex+0x68>
      iunlockput(ip);
    80003e02:	8552                	mv	a0,s4
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	c18080e7          	jalr	-1000(ra) # 80003a1c <iunlockput>
      return 0;
    80003e0c:	8a4e                	mv	s4,s3
    80003e0e:	b7f1                	j	80003dda <namex+0x68>
  len = path - s;
    80003e10:	40998633          	sub	a2,s3,s1
    80003e14:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003e18:	099c5863          	bge	s8,s9,80003ea8 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003e1c:	4639                	li	a2,14
    80003e1e:	85a6                	mv	a1,s1
    80003e20:	8556                	mv	a0,s5
    80003e22:	ffffd097          	auipc	ra,0xffffd
    80003e26:	f6e080e7          	jalr	-146(ra) # 80000d90 <memmove>
    80003e2a:	84ce                	mv	s1,s3
  while(*path == '/')
    80003e2c:	0004c783          	lbu	a5,0(s1)
    80003e30:	01279763          	bne	a5,s2,80003e3e <namex+0xcc>
    path++;
    80003e34:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e36:	0004c783          	lbu	a5,0(s1)
    80003e3a:	ff278de3          	beq	a5,s2,80003e34 <namex+0xc2>
    ilock(ip);
    80003e3e:	8552                	mv	a0,s4
    80003e40:	00000097          	auipc	ra,0x0
    80003e44:	976080e7          	jalr	-1674(ra) # 800037b6 <ilock>
    if(ip->type != T_DIR){
    80003e48:	044a1783          	lh	a5,68(s4)
    80003e4c:	f97791e3          	bne	a5,s7,80003dce <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003e50:	000b0563          	beqz	s6,80003e5a <namex+0xe8>
    80003e54:	0004c783          	lbu	a5,0(s1)
    80003e58:	dfd9                	beqz	a5,80003df6 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e5a:	4601                	li	a2,0
    80003e5c:	85d6                	mv	a1,s5
    80003e5e:	8552                	mv	a0,s4
    80003e60:	00000097          	auipc	ra,0x0
    80003e64:	e62080e7          	jalr	-414(ra) # 80003cc2 <dirlookup>
    80003e68:	89aa                	mv	s3,a0
    80003e6a:	dd41                	beqz	a0,80003e02 <namex+0x90>
    iunlockput(ip);
    80003e6c:	8552                	mv	a0,s4
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	bae080e7          	jalr	-1106(ra) # 80003a1c <iunlockput>
    ip = next;
    80003e76:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e78:	0004c783          	lbu	a5,0(s1)
    80003e7c:	01279763          	bne	a5,s2,80003e8a <namex+0x118>
    path++;
    80003e80:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e82:	0004c783          	lbu	a5,0(s1)
    80003e86:	ff278de3          	beq	a5,s2,80003e80 <namex+0x10e>
  if(*path == 0)
    80003e8a:	cb9d                	beqz	a5,80003ec0 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e8c:	0004c783          	lbu	a5,0(s1)
    80003e90:	89a6                	mv	s3,s1
  len = path - s;
    80003e92:	4c81                	li	s9,0
    80003e94:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e96:	01278963          	beq	a5,s2,80003ea8 <namex+0x136>
    80003e9a:	dbbd                	beqz	a5,80003e10 <namex+0x9e>
    path++;
    80003e9c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e9e:	0009c783          	lbu	a5,0(s3)
    80003ea2:	ff279ce3          	bne	a5,s2,80003e9a <namex+0x128>
    80003ea6:	b7ad                	j	80003e10 <namex+0x9e>
    memmove(name, s, len);
    80003ea8:	2601                	sext.w	a2,a2
    80003eaa:	85a6                	mv	a1,s1
    80003eac:	8556                	mv	a0,s5
    80003eae:	ffffd097          	auipc	ra,0xffffd
    80003eb2:	ee2080e7          	jalr	-286(ra) # 80000d90 <memmove>
    name[len] = 0;
    80003eb6:	9cd6                	add	s9,s9,s5
    80003eb8:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003ebc:	84ce                	mv	s1,s3
    80003ebe:	b7bd                	j	80003e2c <namex+0xba>
  if(nameiparent){
    80003ec0:	f00b0de3          	beqz	s6,80003dda <namex+0x68>
    iput(ip);
    80003ec4:	8552                	mv	a0,s4
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	aae080e7          	jalr	-1362(ra) # 80003974 <iput>
    return 0;
    80003ece:	4a01                	li	s4,0
    80003ed0:	b729                	j	80003dda <namex+0x68>

0000000080003ed2 <dirlink>:
{
    80003ed2:	7139                	addi	sp,sp,-64
    80003ed4:	fc06                	sd	ra,56(sp)
    80003ed6:	f822                	sd	s0,48(sp)
    80003ed8:	f04a                	sd	s2,32(sp)
    80003eda:	ec4e                	sd	s3,24(sp)
    80003edc:	e852                	sd	s4,16(sp)
    80003ede:	0080                	addi	s0,sp,64
    80003ee0:	892a                	mv	s2,a0
    80003ee2:	8a2e                	mv	s4,a1
    80003ee4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ee6:	4601                	li	a2,0
    80003ee8:	00000097          	auipc	ra,0x0
    80003eec:	dda080e7          	jalr	-550(ra) # 80003cc2 <dirlookup>
    80003ef0:	ed25                	bnez	a0,80003f68 <dirlink+0x96>
    80003ef2:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ef4:	04c92483          	lw	s1,76(s2)
    80003ef8:	c49d                	beqz	s1,80003f26 <dirlink+0x54>
    80003efa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003efc:	4741                	li	a4,16
    80003efe:	86a6                	mv	a3,s1
    80003f00:	fc040613          	addi	a2,s0,-64
    80003f04:	4581                	li	a1,0
    80003f06:	854a                	mv	a0,s2
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	b66080e7          	jalr	-1178(ra) # 80003a6e <readi>
    80003f10:	47c1                	li	a5,16
    80003f12:	06f51163          	bne	a0,a5,80003f74 <dirlink+0xa2>
    if(de.inum == 0)
    80003f16:	fc045783          	lhu	a5,-64(s0)
    80003f1a:	c791                	beqz	a5,80003f26 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f1c:	24c1                	addiw	s1,s1,16
    80003f1e:	04c92783          	lw	a5,76(s2)
    80003f22:	fcf4ede3          	bltu	s1,a5,80003efc <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f26:	4639                	li	a2,14
    80003f28:	85d2                	mv	a1,s4
    80003f2a:	fc240513          	addi	a0,s0,-62
    80003f2e:	ffffd097          	auipc	ra,0xffffd
    80003f32:	f0c080e7          	jalr	-244(ra) # 80000e3a <strncpy>
  de.inum = inum;
    80003f36:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f3a:	4741                	li	a4,16
    80003f3c:	86a6                	mv	a3,s1
    80003f3e:	fc040613          	addi	a2,s0,-64
    80003f42:	4581                	li	a1,0
    80003f44:	854a                	mv	a0,s2
    80003f46:	00000097          	auipc	ra,0x0
    80003f4a:	c38080e7          	jalr	-968(ra) # 80003b7e <writei>
    80003f4e:	1541                	addi	a0,a0,-16
    80003f50:	00a03533          	snez	a0,a0
    80003f54:	40a00533          	neg	a0,a0
    80003f58:	74a2                	ld	s1,40(sp)
}
    80003f5a:	70e2                	ld	ra,56(sp)
    80003f5c:	7442                	ld	s0,48(sp)
    80003f5e:	7902                	ld	s2,32(sp)
    80003f60:	69e2                	ld	s3,24(sp)
    80003f62:	6a42                	ld	s4,16(sp)
    80003f64:	6121                	addi	sp,sp,64
    80003f66:	8082                	ret
    iput(ip);
    80003f68:	00000097          	auipc	ra,0x0
    80003f6c:	a0c080e7          	jalr	-1524(ra) # 80003974 <iput>
    return -1;
    80003f70:	557d                	li	a0,-1
    80003f72:	b7e5                	j	80003f5a <dirlink+0x88>
      panic("dirlink read");
    80003f74:	00004517          	auipc	a0,0x4
    80003f78:	58c50513          	addi	a0,a0,1420 # 80008500 <etext+0x500>
    80003f7c:	ffffc097          	auipc	ra,0xffffc
    80003f80:	5e4080e7          	jalr	1508(ra) # 80000560 <panic>

0000000080003f84 <namei>:

struct inode*
namei(char *path)
{
    80003f84:	1101                	addi	sp,sp,-32
    80003f86:	ec06                	sd	ra,24(sp)
    80003f88:	e822                	sd	s0,16(sp)
    80003f8a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f8c:	fe040613          	addi	a2,s0,-32
    80003f90:	4581                	li	a1,0
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	de0080e7          	jalr	-544(ra) # 80003d72 <namex>
}
    80003f9a:	60e2                	ld	ra,24(sp)
    80003f9c:	6442                	ld	s0,16(sp)
    80003f9e:	6105                	addi	sp,sp,32
    80003fa0:	8082                	ret

0000000080003fa2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fa2:	1141                	addi	sp,sp,-16
    80003fa4:	e406                	sd	ra,8(sp)
    80003fa6:	e022                	sd	s0,0(sp)
    80003fa8:	0800                	addi	s0,sp,16
    80003faa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fac:	4585                	li	a1,1
    80003fae:	00000097          	auipc	ra,0x0
    80003fb2:	dc4080e7          	jalr	-572(ra) # 80003d72 <namex>
}
    80003fb6:	60a2                	ld	ra,8(sp)
    80003fb8:	6402                	ld	s0,0(sp)
    80003fba:	0141                	addi	sp,sp,16
    80003fbc:	8082                	ret

0000000080003fbe <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fbe:	1101                	addi	sp,sp,-32
    80003fc0:	ec06                	sd	ra,24(sp)
    80003fc2:	e822                	sd	s0,16(sp)
    80003fc4:	e426                	sd	s1,8(sp)
    80003fc6:	e04a                	sd	s2,0(sp)
    80003fc8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003fca:	0001f917          	auipc	s2,0x1f
    80003fce:	66690913          	addi	s2,s2,1638 # 80023630 <log>
    80003fd2:	01892583          	lw	a1,24(s2)
    80003fd6:	02892503          	lw	a0,40(s2)
    80003fda:	fffff097          	auipc	ra,0xfffff
    80003fde:	fa8080e7          	jalr	-88(ra) # 80002f82 <bread>
    80003fe2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fe4:	02c92603          	lw	a2,44(s2)
    80003fe8:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fea:	00c05f63          	blez	a2,80004008 <write_head+0x4a>
    80003fee:	0001f717          	auipc	a4,0x1f
    80003ff2:	67270713          	addi	a4,a4,1650 # 80023660 <log+0x30>
    80003ff6:	87aa                	mv	a5,a0
    80003ff8:	060a                	slli	a2,a2,0x2
    80003ffa:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003ffc:	4314                	lw	a3,0(a4)
    80003ffe:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004000:	0711                	addi	a4,a4,4
    80004002:	0791                	addi	a5,a5,4
    80004004:	fec79ce3          	bne	a5,a2,80003ffc <write_head+0x3e>
  }
  bwrite(buf);
    80004008:	8526                	mv	a0,s1
    8000400a:	fffff097          	auipc	ra,0xfffff
    8000400e:	06a080e7          	jalr	106(ra) # 80003074 <bwrite>
  brelse(buf);
    80004012:	8526                	mv	a0,s1
    80004014:	fffff097          	auipc	ra,0xfffff
    80004018:	09e080e7          	jalr	158(ra) # 800030b2 <brelse>
}
    8000401c:	60e2                	ld	ra,24(sp)
    8000401e:	6442                	ld	s0,16(sp)
    80004020:	64a2                	ld	s1,8(sp)
    80004022:	6902                	ld	s2,0(sp)
    80004024:	6105                	addi	sp,sp,32
    80004026:	8082                	ret

0000000080004028 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004028:	0001f797          	auipc	a5,0x1f
    8000402c:	6347a783          	lw	a5,1588(a5) # 8002365c <log+0x2c>
    80004030:	0af05d63          	blez	a5,800040ea <install_trans+0xc2>
{
    80004034:	7139                	addi	sp,sp,-64
    80004036:	fc06                	sd	ra,56(sp)
    80004038:	f822                	sd	s0,48(sp)
    8000403a:	f426                	sd	s1,40(sp)
    8000403c:	f04a                	sd	s2,32(sp)
    8000403e:	ec4e                	sd	s3,24(sp)
    80004040:	e852                	sd	s4,16(sp)
    80004042:	e456                	sd	s5,8(sp)
    80004044:	e05a                	sd	s6,0(sp)
    80004046:	0080                	addi	s0,sp,64
    80004048:	8b2a                	mv	s6,a0
    8000404a:	0001fa97          	auipc	s5,0x1f
    8000404e:	616a8a93          	addi	s5,s5,1558 # 80023660 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004052:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004054:	0001f997          	auipc	s3,0x1f
    80004058:	5dc98993          	addi	s3,s3,1500 # 80023630 <log>
    8000405c:	a00d                	j	8000407e <install_trans+0x56>
    brelse(lbuf);
    8000405e:	854a                	mv	a0,s2
    80004060:	fffff097          	auipc	ra,0xfffff
    80004064:	052080e7          	jalr	82(ra) # 800030b2 <brelse>
    brelse(dbuf);
    80004068:	8526                	mv	a0,s1
    8000406a:	fffff097          	auipc	ra,0xfffff
    8000406e:	048080e7          	jalr	72(ra) # 800030b2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004072:	2a05                	addiw	s4,s4,1
    80004074:	0a91                	addi	s5,s5,4
    80004076:	02c9a783          	lw	a5,44(s3)
    8000407a:	04fa5e63          	bge	s4,a5,800040d6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000407e:	0189a583          	lw	a1,24(s3)
    80004082:	014585bb          	addw	a1,a1,s4
    80004086:	2585                	addiw	a1,a1,1
    80004088:	0289a503          	lw	a0,40(s3)
    8000408c:	fffff097          	auipc	ra,0xfffff
    80004090:	ef6080e7          	jalr	-266(ra) # 80002f82 <bread>
    80004094:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004096:	000aa583          	lw	a1,0(s5)
    8000409a:	0289a503          	lw	a0,40(s3)
    8000409e:	fffff097          	auipc	ra,0xfffff
    800040a2:	ee4080e7          	jalr	-284(ra) # 80002f82 <bread>
    800040a6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040a8:	40000613          	li	a2,1024
    800040ac:	05890593          	addi	a1,s2,88
    800040b0:	05850513          	addi	a0,a0,88
    800040b4:	ffffd097          	auipc	ra,0xffffd
    800040b8:	cdc080e7          	jalr	-804(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040bc:	8526                	mv	a0,s1
    800040be:	fffff097          	auipc	ra,0xfffff
    800040c2:	fb6080e7          	jalr	-74(ra) # 80003074 <bwrite>
    if(recovering == 0)
    800040c6:	f80b1ce3          	bnez	s6,8000405e <install_trans+0x36>
      bunpin(dbuf);
    800040ca:	8526                	mv	a0,s1
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	0be080e7          	jalr	190(ra) # 8000318a <bunpin>
    800040d4:	b769                	j	8000405e <install_trans+0x36>
}
    800040d6:	70e2                	ld	ra,56(sp)
    800040d8:	7442                	ld	s0,48(sp)
    800040da:	74a2                	ld	s1,40(sp)
    800040dc:	7902                	ld	s2,32(sp)
    800040de:	69e2                	ld	s3,24(sp)
    800040e0:	6a42                	ld	s4,16(sp)
    800040e2:	6aa2                	ld	s5,8(sp)
    800040e4:	6b02                	ld	s6,0(sp)
    800040e6:	6121                	addi	sp,sp,64
    800040e8:	8082                	ret
    800040ea:	8082                	ret

00000000800040ec <initlog>:
{
    800040ec:	7179                	addi	sp,sp,-48
    800040ee:	f406                	sd	ra,40(sp)
    800040f0:	f022                	sd	s0,32(sp)
    800040f2:	ec26                	sd	s1,24(sp)
    800040f4:	e84a                	sd	s2,16(sp)
    800040f6:	e44e                	sd	s3,8(sp)
    800040f8:	1800                	addi	s0,sp,48
    800040fa:	892a                	mv	s2,a0
    800040fc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040fe:	0001f497          	auipc	s1,0x1f
    80004102:	53248493          	addi	s1,s1,1330 # 80023630 <log>
    80004106:	00004597          	auipc	a1,0x4
    8000410a:	40a58593          	addi	a1,a1,1034 # 80008510 <etext+0x510>
    8000410e:	8526                	mv	a0,s1
    80004110:	ffffd097          	auipc	ra,0xffffd
    80004114:	a98080e7          	jalr	-1384(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    80004118:	0149a583          	lw	a1,20(s3)
    8000411c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000411e:	0109a783          	lw	a5,16(s3)
    80004122:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004124:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004128:	854a                	mv	a0,s2
    8000412a:	fffff097          	auipc	ra,0xfffff
    8000412e:	e58080e7          	jalr	-424(ra) # 80002f82 <bread>
  log.lh.n = lh->n;
    80004132:	4d30                	lw	a2,88(a0)
    80004134:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004136:	00c05f63          	blez	a2,80004154 <initlog+0x68>
    8000413a:	87aa                	mv	a5,a0
    8000413c:	0001f717          	auipc	a4,0x1f
    80004140:	52470713          	addi	a4,a4,1316 # 80023660 <log+0x30>
    80004144:	060a                	slli	a2,a2,0x2
    80004146:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004148:	4ff4                	lw	a3,92(a5)
    8000414a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000414c:	0791                	addi	a5,a5,4
    8000414e:	0711                	addi	a4,a4,4
    80004150:	fec79ce3          	bne	a5,a2,80004148 <initlog+0x5c>
  brelse(buf);
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	f5e080e7          	jalr	-162(ra) # 800030b2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000415c:	4505                	li	a0,1
    8000415e:	00000097          	auipc	ra,0x0
    80004162:	eca080e7          	jalr	-310(ra) # 80004028 <install_trans>
  log.lh.n = 0;
    80004166:	0001f797          	auipc	a5,0x1f
    8000416a:	4e07ab23          	sw	zero,1270(a5) # 8002365c <log+0x2c>
  write_head(); // clear the log
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	e50080e7          	jalr	-432(ra) # 80003fbe <write_head>
}
    80004176:	70a2                	ld	ra,40(sp)
    80004178:	7402                	ld	s0,32(sp)
    8000417a:	64e2                	ld	s1,24(sp)
    8000417c:	6942                	ld	s2,16(sp)
    8000417e:	69a2                	ld	s3,8(sp)
    80004180:	6145                	addi	sp,sp,48
    80004182:	8082                	ret

0000000080004184 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004184:	1101                	addi	sp,sp,-32
    80004186:	ec06                	sd	ra,24(sp)
    80004188:	e822                	sd	s0,16(sp)
    8000418a:	e426                	sd	s1,8(sp)
    8000418c:	e04a                	sd	s2,0(sp)
    8000418e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004190:	0001f517          	auipc	a0,0x1f
    80004194:	4a050513          	addi	a0,a0,1184 # 80023630 <log>
    80004198:	ffffd097          	auipc	ra,0xffffd
    8000419c:	aa0080e7          	jalr	-1376(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    800041a0:	0001f497          	auipc	s1,0x1f
    800041a4:	49048493          	addi	s1,s1,1168 # 80023630 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041a8:	4979                	li	s2,30
    800041aa:	a039                	j	800041b8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800041ac:	85a6                	mv	a1,s1
    800041ae:	8526                	mv	a0,s1
    800041b0:	ffffe097          	auipc	ra,0xffffe
    800041b4:	f4c080e7          	jalr	-180(ra) # 800020fc <sleep>
    if(log.committing){
    800041b8:	50dc                	lw	a5,36(s1)
    800041ba:	fbed                	bnez	a5,800041ac <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041bc:	5098                	lw	a4,32(s1)
    800041be:	2705                	addiw	a4,a4,1
    800041c0:	0027179b          	slliw	a5,a4,0x2
    800041c4:	9fb9                	addw	a5,a5,a4
    800041c6:	0017979b          	slliw	a5,a5,0x1
    800041ca:	54d4                	lw	a3,44(s1)
    800041cc:	9fb5                	addw	a5,a5,a3
    800041ce:	00f95963          	bge	s2,a5,800041e0 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041d2:	85a6                	mv	a1,s1
    800041d4:	8526                	mv	a0,s1
    800041d6:	ffffe097          	auipc	ra,0xffffe
    800041da:	f26080e7          	jalr	-218(ra) # 800020fc <sleep>
    800041de:	bfe9                	j	800041b8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800041e0:	0001f517          	auipc	a0,0x1f
    800041e4:	45050513          	addi	a0,a0,1104 # 80023630 <log>
    800041e8:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800041ea:	ffffd097          	auipc	ra,0xffffd
    800041ee:	b02080e7          	jalr	-1278(ra) # 80000cec <release>
      break;
    }
  }
}
    800041f2:	60e2                	ld	ra,24(sp)
    800041f4:	6442                	ld	s0,16(sp)
    800041f6:	64a2                	ld	s1,8(sp)
    800041f8:	6902                	ld	s2,0(sp)
    800041fa:	6105                	addi	sp,sp,32
    800041fc:	8082                	ret

00000000800041fe <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041fe:	7139                	addi	sp,sp,-64
    80004200:	fc06                	sd	ra,56(sp)
    80004202:	f822                	sd	s0,48(sp)
    80004204:	f426                	sd	s1,40(sp)
    80004206:	f04a                	sd	s2,32(sp)
    80004208:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000420a:	0001f497          	auipc	s1,0x1f
    8000420e:	42648493          	addi	s1,s1,1062 # 80023630 <log>
    80004212:	8526                	mv	a0,s1
    80004214:	ffffd097          	auipc	ra,0xffffd
    80004218:	a24080e7          	jalr	-1500(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    8000421c:	509c                	lw	a5,32(s1)
    8000421e:	37fd                	addiw	a5,a5,-1
    80004220:	0007891b          	sext.w	s2,a5
    80004224:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004226:	50dc                	lw	a5,36(s1)
    80004228:	e7b9                	bnez	a5,80004276 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    8000422a:	06091163          	bnez	s2,8000428c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000422e:	0001f497          	auipc	s1,0x1f
    80004232:	40248493          	addi	s1,s1,1026 # 80023630 <log>
    80004236:	4785                	li	a5,1
    80004238:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000423a:	8526                	mv	a0,s1
    8000423c:	ffffd097          	auipc	ra,0xffffd
    80004240:	ab0080e7          	jalr	-1360(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004244:	54dc                	lw	a5,44(s1)
    80004246:	06f04763          	bgtz	a5,800042b4 <end_op+0xb6>
    acquire(&log.lock);
    8000424a:	0001f497          	auipc	s1,0x1f
    8000424e:	3e648493          	addi	s1,s1,998 # 80023630 <log>
    80004252:	8526                	mv	a0,s1
    80004254:	ffffd097          	auipc	ra,0xffffd
    80004258:	9e4080e7          	jalr	-1564(ra) # 80000c38 <acquire>
    log.committing = 0;
    8000425c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004260:	8526                	mv	a0,s1
    80004262:	ffffe097          	auipc	ra,0xffffe
    80004266:	efe080e7          	jalr	-258(ra) # 80002160 <wakeup>
    release(&log.lock);
    8000426a:	8526                	mv	a0,s1
    8000426c:	ffffd097          	auipc	ra,0xffffd
    80004270:	a80080e7          	jalr	-1408(ra) # 80000cec <release>
}
    80004274:	a815                	j	800042a8 <end_op+0xaa>
    80004276:	ec4e                	sd	s3,24(sp)
    80004278:	e852                	sd	s4,16(sp)
    8000427a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000427c:	00004517          	auipc	a0,0x4
    80004280:	29c50513          	addi	a0,a0,668 # 80008518 <etext+0x518>
    80004284:	ffffc097          	auipc	ra,0xffffc
    80004288:	2dc080e7          	jalr	732(ra) # 80000560 <panic>
    wakeup(&log);
    8000428c:	0001f497          	auipc	s1,0x1f
    80004290:	3a448493          	addi	s1,s1,932 # 80023630 <log>
    80004294:	8526                	mv	a0,s1
    80004296:	ffffe097          	auipc	ra,0xffffe
    8000429a:	eca080e7          	jalr	-310(ra) # 80002160 <wakeup>
  release(&log.lock);
    8000429e:	8526                	mv	a0,s1
    800042a0:	ffffd097          	auipc	ra,0xffffd
    800042a4:	a4c080e7          	jalr	-1460(ra) # 80000cec <release>
}
    800042a8:	70e2                	ld	ra,56(sp)
    800042aa:	7442                	ld	s0,48(sp)
    800042ac:	74a2                	ld	s1,40(sp)
    800042ae:	7902                	ld	s2,32(sp)
    800042b0:	6121                	addi	sp,sp,64
    800042b2:	8082                	ret
    800042b4:	ec4e                	sd	s3,24(sp)
    800042b6:	e852                	sd	s4,16(sp)
    800042b8:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ba:	0001fa97          	auipc	s5,0x1f
    800042be:	3a6a8a93          	addi	s5,s5,934 # 80023660 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042c2:	0001fa17          	auipc	s4,0x1f
    800042c6:	36ea0a13          	addi	s4,s4,878 # 80023630 <log>
    800042ca:	018a2583          	lw	a1,24(s4)
    800042ce:	012585bb          	addw	a1,a1,s2
    800042d2:	2585                	addiw	a1,a1,1
    800042d4:	028a2503          	lw	a0,40(s4)
    800042d8:	fffff097          	auipc	ra,0xfffff
    800042dc:	caa080e7          	jalr	-854(ra) # 80002f82 <bread>
    800042e0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042e2:	000aa583          	lw	a1,0(s5)
    800042e6:	028a2503          	lw	a0,40(s4)
    800042ea:	fffff097          	auipc	ra,0xfffff
    800042ee:	c98080e7          	jalr	-872(ra) # 80002f82 <bread>
    800042f2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042f4:	40000613          	li	a2,1024
    800042f8:	05850593          	addi	a1,a0,88
    800042fc:	05848513          	addi	a0,s1,88
    80004300:	ffffd097          	auipc	ra,0xffffd
    80004304:	a90080e7          	jalr	-1392(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    80004308:	8526                	mv	a0,s1
    8000430a:	fffff097          	auipc	ra,0xfffff
    8000430e:	d6a080e7          	jalr	-662(ra) # 80003074 <bwrite>
    brelse(from);
    80004312:	854e                	mv	a0,s3
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	d9e080e7          	jalr	-610(ra) # 800030b2 <brelse>
    brelse(to);
    8000431c:	8526                	mv	a0,s1
    8000431e:	fffff097          	auipc	ra,0xfffff
    80004322:	d94080e7          	jalr	-620(ra) # 800030b2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004326:	2905                	addiw	s2,s2,1
    80004328:	0a91                	addi	s5,s5,4
    8000432a:	02ca2783          	lw	a5,44(s4)
    8000432e:	f8f94ee3          	blt	s2,a5,800042ca <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004332:	00000097          	auipc	ra,0x0
    80004336:	c8c080e7          	jalr	-884(ra) # 80003fbe <write_head>
    install_trans(0); // Now install writes to home locations
    8000433a:	4501                	li	a0,0
    8000433c:	00000097          	auipc	ra,0x0
    80004340:	cec080e7          	jalr	-788(ra) # 80004028 <install_trans>
    log.lh.n = 0;
    80004344:	0001f797          	auipc	a5,0x1f
    80004348:	3007ac23          	sw	zero,792(a5) # 8002365c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000434c:	00000097          	auipc	ra,0x0
    80004350:	c72080e7          	jalr	-910(ra) # 80003fbe <write_head>
    80004354:	69e2                	ld	s3,24(sp)
    80004356:	6a42                	ld	s4,16(sp)
    80004358:	6aa2                	ld	s5,8(sp)
    8000435a:	bdc5                	j	8000424a <end_op+0x4c>

000000008000435c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	e04a                	sd	s2,0(sp)
    80004366:	1000                	addi	s0,sp,32
    80004368:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000436a:	0001f917          	auipc	s2,0x1f
    8000436e:	2c690913          	addi	s2,s2,710 # 80023630 <log>
    80004372:	854a                	mv	a0,s2
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	8c4080e7          	jalr	-1852(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000437c:	02c92603          	lw	a2,44(s2)
    80004380:	47f5                	li	a5,29
    80004382:	06c7c563          	blt	a5,a2,800043ec <log_write+0x90>
    80004386:	0001f797          	auipc	a5,0x1f
    8000438a:	2c67a783          	lw	a5,710(a5) # 8002364c <log+0x1c>
    8000438e:	37fd                	addiw	a5,a5,-1
    80004390:	04f65e63          	bge	a2,a5,800043ec <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004394:	0001f797          	auipc	a5,0x1f
    80004398:	2bc7a783          	lw	a5,700(a5) # 80023650 <log+0x20>
    8000439c:	06f05063          	blez	a5,800043fc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043a0:	4781                	li	a5,0
    800043a2:	06c05563          	blez	a2,8000440c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043a6:	44cc                	lw	a1,12(s1)
    800043a8:	0001f717          	auipc	a4,0x1f
    800043ac:	2b870713          	addi	a4,a4,696 # 80023660 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800043b0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043b2:	4314                	lw	a3,0(a4)
    800043b4:	04b68c63          	beq	a3,a1,8000440c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800043b8:	2785                	addiw	a5,a5,1
    800043ba:	0711                	addi	a4,a4,4
    800043bc:	fef61be3          	bne	a2,a5,800043b2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043c0:	0621                	addi	a2,a2,8
    800043c2:	060a                	slli	a2,a2,0x2
    800043c4:	0001f797          	auipc	a5,0x1f
    800043c8:	26c78793          	addi	a5,a5,620 # 80023630 <log>
    800043cc:	97b2                	add	a5,a5,a2
    800043ce:	44d8                	lw	a4,12(s1)
    800043d0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043d2:	8526                	mv	a0,s1
    800043d4:	fffff097          	auipc	ra,0xfffff
    800043d8:	d7a080e7          	jalr	-646(ra) # 8000314e <bpin>
    log.lh.n++;
    800043dc:	0001f717          	auipc	a4,0x1f
    800043e0:	25470713          	addi	a4,a4,596 # 80023630 <log>
    800043e4:	575c                	lw	a5,44(a4)
    800043e6:	2785                	addiw	a5,a5,1
    800043e8:	d75c                	sw	a5,44(a4)
    800043ea:	a82d                	j	80004424 <log_write+0xc8>
    panic("too big a transaction");
    800043ec:	00004517          	auipc	a0,0x4
    800043f0:	13c50513          	addi	a0,a0,316 # 80008528 <etext+0x528>
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	16c080e7          	jalr	364(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    800043fc:	00004517          	auipc	a0,0x4
    80004400:	14450513          	addi	a0,a0,324 # 80008540 <etext+0x540>
    80004404:	ffffc097          	auipc	ra,0xffffc
    80004408:	15c080e7          	jalr	348(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    8000440c:	00878693          	addi	a3,a5,8
    80004410:	068a                	slli	a3,a3,0x2
    80004412:	0001f717          	auipc	a4,0x1f
    80004416:	21e70713          	addi	a4,a4,542 # 80023630 <log>
    8000441a:	9736                	add	a4,a4,a3
    8000441c:	44d4                	lw	a3,12(s1)
    8000441e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004420:	faf609e3          	beq	a2,a5,800043d2 <log_write+0x76>
  }
  release(&log.lock);
    80004424:	0001f517          	auipc	a0,0x1f
    80004428:	20c50513          	addi	a0,a0,524 # 80023630 <log>
    8000442c:	ffffd097          	auipc	ra,0xffffd
    80004430:	8c0080e7          	jalr	-1856(ra) # 80000cec <release>
}
    80004434:	60e2                	ld	ra,24(sp)
    80004436:	6442                	ld	s0,16(sp)
    80004438:	64a2                	ld	s1,8(sp)
    8000443a:	6902                	ld	s2,0(sp)
    8000443c:	6105                	addi	sp,sp,32
    8000443e:	8082                	ret

0000000080004440 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004440:	1101                	addi	sp,sp,-32
    80004442:	ec06                	sd	ra,24(sp)
    80004444:	e822                	sd	s0,16(sp)
    80004446:	e426                	sd	s1,8(sp)
    80004448:	e04a                	sd	s2,0(sp)
    8000444a:	1000                	addi	s0,sp,32
    8000444c:	84aa                	mv	s1,a0
    8000444e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004450:	00004597          	auipc	a1,0x4
    80004454:	11058593          	addi	a1,a1,272 # 80008560 <etext+0x560>
    80004458:	0521                	addi	a0,a0,8
    8000445a:	ffffc097          	auipc	ra,0xffffc
    8000445e:	74e080e7          	jalr	1870(ra) # 80000ba8 <initlock>
  lk->name = name;
    80004462:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004466:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000446a:	0204a423          	sw	zero,40(s1)
}
    8000446e:	60e2                	ld	ra,24(sp)
    80004470:	6442                	ld	s0,16(sp)
    80004472:	64a2                	ld	s1,8(sp)
    80004474:	6902                	ld	s2,0(sp)
    80004476:	6105                	addi	sp,sp,32
    80004478:	8082                	ret

000000008000447a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000447a:	1101                	addi	sp,sp,-32
    8000447c:	ec06                	sd	ra,24(sp)
    8000447e:	e822                	sd	s0,16(sp)
    80004480:	e426                	sd	s1,8(sp)
    80004482:	e04a                	sd	s2,0(sp)
    80004484:	1000                	addi	s0,sp,32
    80004486:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004488:	00850913          	addi	s2,a0,8
    8000448c:	854a                	mv	a0,s2
    8000448e:	ffffc097          	auipc	ra,0xffffc
    80004492:	7aa080e7          	jalr	1962(ra) # 80000c38 <acquire>
  while (lk->locked) {
    80004496:	409c                	lw	a5,0(s1)
    80004498:	cb89                	beqz	a5,800044aa <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000449a:	85ca                	mv	a1,s2
    8000449c:	8526                	mv	a0,s1
    8000449e:	ffffe097          	auipc	ra,0xffffe
    800044a2:	c5e080e7          	jalr	-930(ra) # 800020fc <sleep>
  while (lk->locked) {
    800044a6:	409c                	lw	a5,0(s1)
    800044a8:	fbed                	bnez	a5,8000449a <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044aa:	4785                	li	a5,1
    800044ac:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044ae:	ffffd097          	auipc	ra,0xffffd
    800044b2:	5a4080e7          	jalr	1444(ra) # 80001a52 <myproc>
    800044b6:	591c                	lw	a5,48(a0)
    800044b8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044ba:	854a                	mv	a0,s2
    800044bc:	ffffd097          	auipc	ra,0xffffd
    800044c0:	830080e7          	jalr	-2000(ra) # 80000cec <release>
}
    800044c4:	60e2                	ld	ra,24(sp)
    800044c6:	6442                	ld	s0,16(sp)
    800044c8:	64a2                	ld	s1,8(sp)
    800044ca:	6902                	ld	s2,0(sp)
    800044cc:	6105                	addi	sp,sp,32
    800044ce:	8082                	ret

00000000800044d0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044d0:	1101                	addi	sp,sp,-32
    800044d2:	ec06                	sd	ra,24(sp)
    800044d4:	e822                	sd	s0,16(sp)
    800044d6:	e426                	sd	s1,8(sp)
    800044d8:	e04a                	sd	s2,0(sp)
    800044da:	1000                	addi	s0,sp,32
    800044dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044de:	00850913          	addi	s2,a0,8
    800044e2:	854a                	mv	a0,s2
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	754080e7          	jalr	1876(ra) # 80000c38 <acquire>
  lk->locked = 0;
    800044ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044f0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044f4:	8526                	mv	a0,s1
    800044f6:	ffffe097          	auipc	ra,0xffffe
    800044fa:	c6a080e7          	jalr	-918(ra) # 80002160 <wakeup>
  release(&lk->lk);
    800044fe:	854a                	mv	a0,s2
    80004500:	ffffc097          	auipc	ra,0xffffc
    80004504:	7ec080e7          	jalr	2028(ra) # 80000cec <release>
}
    80004508:	60e2                	ld	ra,24(sp)
    8000450a:	6442                	ld	s0,16(sp)
    8000450c:	64a2                	ld	s1,8(sp)
    8000450e:	6902                	ld	s2,0(sp)
    80004510:	6105                	addi	sp,sp,32
    80004512:	8082                	ret

0000000080004514 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004514:	7179                	addi	sp,sp,-48
    80004516:	f406                	sd	ra,40(sp)
    80004518:	f022                	sd	s0,32(sp)
    8000451a:	ec26                	sd	s1,24(sp)
    8000451c:	e84a                	sd	s2,16(sp)
    8000451e:	1800                	addi	s0,sp,48
    80004520:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004522:	00850913          	addi	s2,a0,8
    80004526:	854a                	mv	a0,s2
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	710080e7          	jalr	1808(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004530:	409c                	lw	a5,0(s1)
    80004532:	ef91                	bnez	a5,8000454e <holdingsleep+0x3a>
    80004534:	4481                	li	s1,0
  release(&lk->lk);
    80004536:	854a                	mv	a0,s2
    80004538:	ffffc097          	auipc	ra,0xffffc
    8000453c:	7b4080e7          	jalr	1972(ra) # 80000cec <release>
  return r;
}
    80004540:	8526                	mv	a0,s1
    80004542:	70a2                	ld	ra,40(sp)
    80004544:	7402                	ld	s0,32(sp)
    80004546:	64e2                	ld	s1,24(sp)
    80004548:	6942                	ld	s2,16(sp)
    8000454a:	6145                	addi	sp,sp,48
    8000454c:	8082                	ret
    8000454e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004550:	0284a983          	lw	s3,40(s1)
    80004554:	ffffd097          	auipc	ra,0xffffd
    80004558:	4fe080e7          	jalr	1278(ra) # 80001a52 <myproc>
    8000455c:	5904                	lw	s1,48(a0)
    8000455e:	413484b3          	sub	s1,s1,s3
    80004562:	0014b493          	seqz	s1,s1
    80004566:	69a2                	ld	s3,8(sp)
    80004568:	b7f9                	j	80004536 <holdingsleep+0x22>

000000008000456a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000456a:	1141                	addi	sp,sp,-16
    8000456c:	e406                	sd	ra,8(sp)
    8000456e:	e022                	sd	s0,0(sp)
    80004570:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004572:	00004597          	auipc	a1,0x4
    80004576:	ffe58593          	addi	a1,a1,-2 # 80008570 <etext+0x570>
    8000457a:	0001f517          	auipc	a0,0x1f
    8000457e:	1fe50513          	addi	a0,a0,510 # 80023778 <ftable>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	626080e7          	jalr	1574(ra) # 80000ba8 <initlock>
}
    8000458a:	60a2                	ld	ra,8(sp)
    8000458c:	6402                	ld	s0,0(sp)
    8000458e:	0141                	addi	sp,sp,16
    80004590:	8082                	ret

0000000080004592 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004592:	1101                	addi	sp,sp,-32
    80004594:	ec06                	sd	ra,24(sp)
    80004596:	e822                	sd	s0,16(sp)
    80004598:	e426                	sd	s1,8(sp)
    8000459a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000459c:	0001f517          	auipc	a0,0x1f
    800045a0:	1dc50513          	addi	a0,a0,476 # 80023778 <ftable>
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	694080e7          	jalr	1684(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045ac:	0001f497          	auipc	s1,0x1f
    800045b0:	1e448493          	addi	s1,s1,484 # 80023790 <ftable+0x18>
    800045b4:	00020717          	auipc	a4,0x20
    800045b8:	17c70713          	addi	a4,a4,380 # 80024730 <sem_table>
    if(f->ref == 0){
    800045bc:	40dc                	lw	a5,4(s1)
    800045be:	cf99                	beqz	a5,800045dc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045c0:	02848493          	addi	s1,s1,40
    800045c4:	fee49ce3          	bne	s1,a4,800045bc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045c8:	0001f517          	auipc	a0,0x1f
    800045cc:	1b050513          	addi	a0,a0,432 # 80023778 <ftable>
    800045d0:	ffffc097          	auipc	ra,0xffffc
    800045d4:	71c080e7          	jalr	1820(ra) # 80000cec <release>
  return 0;
    800045d8:	4481                	li	s1,0
    800045da:	a819                	j	800045f0 <filealloc+0x5e>
      f->ref = 1;
    800045dc:	4785                	li	a5,1
    800045de:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045e0:	0001f517          	auipc	a0,0x1f
    800045e4:	19850513          	addi	a0,a0,408 # 80023778 <ftable>
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	704080e7          	jalr	1796(ra) # 80000cec <release>
}
    800045f0:	8526                	mv	a0,s1
    800045f2:	60e2                	ld	ra,24(sp)
    800045f4:	6442                	ld	s0,16(sp)
    800045f6:	64a2                	ld	s1,8(sp)
    800045f8:	6105                	addi	sp,sp,32
    800045fa:	8082                	ret

00000000800045fc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045fc:	1101                	addi	sp,sp,-32
    800045fe:	ec06                	sd	ra,24(sp)
    80004600:	e822                	sd	s0,16(sp)
    80004602:	e426                	sd	s1,8(sp)
    80004604:	1000                	addi	s0,sp,32
    80004606:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004608:	0001f517          	auipc	a0,0x1f
    8000460c:	17050513          	addi	a0,a0,368 # 80023778 <ftable>
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	628080e7          	jalr	1576(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004618:	40dc                	lw	a5,4(s1)
    8000461a:	02f05263          	blez	a5,8000463e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000461e:	2785                	addiw	a5,a5,1
    80004620:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004622:	0001f517          	auipc	a0,0x1f
    80004626:	15650513          	addi	a0,a0,342 # 80023778 <ftable>
    8000462a:	ffffc097          	auipc	ra,0xffffc
    8000462e:	6c2080e7          	jalr	1730(ra) # 80000cec <release>
  return f;
}
    80004632:	8526                	mv	a0,s1
    80004634:	60e2                	ld	ra,24(sp)
    80004636:	6442                	ld	s0,16(sp)
    80004638:	64a2                	ld	s1,8(sp)
    8000463a:	6105                	addi	sp,sp,32
    8000463c:	8082                	ret
    panic("filedup");
    8000463e:	00004517          	auipc	a0,0x4
    80004642:	f3a50513          	addi	a0,a0,-198 # 80008578 <etext+0x578>
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>

000000008000464e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000464e:	7139                	addi	sp,sp,-64
    80004650:	fc06                	sd	ra,56(sp)
    80004652:	f822                	sd	s0,48(sp)
    80004654:	f426                	sd	s1,40(sp)
    80004656:	0080                	addi	s0,sp,64
    80004658:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000465a:	0001f517          	auipc	a0,0x1f
    8000465e:	11e50513          	addi	a0,a0,286 # 80023778 <ftable>
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	5d6080e7          	jalr	1494(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    8000466a:	40dc                	lw	a5,4(s1)
    8000466c:	04f05c63          	blez	a5,800046c4 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004670:	37fd                	addiw	a5,a5,-1
    80004672:	0007871b          	sext.w	a4,a5
    80004676:	c0dc                	sw	a5,4(s1)
    80004678:	06e04263          	bgtz	a4,800046dc <fileclose+0x8e>
    8000467c:	f04a                	sd	s2,32(sp)
    8000467e:	ec4e                	sd	s3,24(sp)
    80004680:	e852                	sd	s4,16(sp)
    80004682:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004684:	0004a903          	lw	s2,0(s1)
    80004688:	0094ca83          	lbu	s5,9(s1)
    8000468c:	0104ba03          	ld	s4,16(s1)
    80004690:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004694:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004698:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000469c:	0001f517          	auipc	a0,0x1f
    800046a0:	0dc50513          	addi	a0,a0,220 # 80023778 <ftable>
    800046a4:	ffffc097          	auipc	ra,0xffffc
    800046a8:	648080e7          	jalr	1608(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    800046ac:	4785                	li	a5,1
    800046ae:	04f90463          	beq	s2,a5,800046f6 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046b2:	3979                	addiw	s2,s2,-2
    800046b4:	4785                	li	a5,1
    800046b6:	0527fb63          	bgeu	a5,s2,8000470c <fileclose+0xbe>
    800046ba:	7902                	ld	s2,32(sp)
    800046bc:	69e2                	ld	s3,24(sp)
    800046be:	6a42                	ld	s4,16(sp)
    800046c0:	6aa2                	ld	s5,8(sp)
    800046c2:	a02d                	j	800046ec <fileclose+0x9e>
    800046c4:	f04a                	sd	s2,32(sp)
    800046c6:	ec4e                	sd	s3,24(sp)
    800046c8:	e852                	sd	s4,16(sp)
    800046ca:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800046cc:	00004517          	auipc	a0,0x4
    800046d0:	eb450513          	addi	a0,a0,-332 # 80008580 <etext+0x580>
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	e8c080e7          	jalr	-372(ra) # 80000560 <panic>
    release(&ftable.lock);
    800046dc:	0001f517          	auipc	a0,0x1f
    800046e0:	09c50513          	addi	a0,a0,156 # 80023778 <ftable>
    800046e4:	ffffc097          	auipc	ra,0xffffc
    800046e8:	608080e7          	jalr	1544(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800046ec:	70e2                	ld	ra,56(sp)
    800046ee:	7442                	ld	s0,48(sp)
    800046f0:	74a2                	ld	s1,40(sp)
    800046f2:	6121                	addi	sp,sp,64
    800046f4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046f6:	85d6                	mv	a1,s5
    800046f8:	8552                	mv	a0,s4
    800046fa:	00000097          	auipc	ra,0x0
    800046fe:	3a2080e7          	jalr	930(ra) # 80004a9c <pipeclose>
    80004702:	7902                	ld	s2,32(sp)
    80004704:	69e2                	ld	s3,24(sp)
    80004706:	6a42                	ld	s4,16(sp)
    80004708:	6aa2                	ld	s5,8(sp)
    8000470a:	b7cd                	j	800046ec <fileclose+0x9e>
    begin_op();
    8000470c:	00000097          	auipc	ra,0x0
    80004710:	a78080e7          	jalr	-1416(ra) # 80004184 <begin_op>
    iput(ff.ip);
    80004714:	854e                	mv	a0,s3
    80004716:	fffff097          	auipc	ra,0xfffff
    8000471a:	25e080e7          	jalr	606(ra) # 80003974 <iput>
    end_op();
    8000471e:	00000097          	auipc	ra,0x0
    80004722:	ae0080e7          	jalr	-1312(ra) # 800041fe <end_op>
    80004726:	7902                	ld	s2,32(sp)
    80004728:	69e2                	ld	s3,24(sp)
    8000472a:	6a42                	ld	s4,16(sp)
    8000472c:	6aa2                	ld	s5,8(sp)
    8000472e:	bf7d                	j	800046ec <fileclose+0x9e>

0000000080004730 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004730:	715d                	addi	sp,sp,-80
    80004732:	e486                	sd	ra,72(sp)
    80004734:	e0a2                	sd	s0,64(sp)
    80004736:	fc26                	sd	s1,56(sp)
    80004738:	f44e                	sd	s3,40(sp)
    8000473a:	0880                	addi	s0,sp,80
    8000473c:	84aa                	mv	s1,a0
    8000473e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004740:	ffffd097          	auipc	ra,0xffffd
    80004744:	312080e7          	jalr	786(ra) # 80001a52 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004748:	409c                	lw	a5,0(s1)
    8000474a:	37f9                	addiw	a5,a5,-2
    8000474c:	4705                	li	a4,1
    8000474e:	04f76863          	bltu	a4,a5,8000479e <filestat+0x6e>
    80004752:	f84a                	sd	s2,48(sp)
    80004754:	892a                	mv	s2,a0
    ilock(f->ip);
    80004756:	6c88                	ld	a0,24(s1)
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	05e080e7          	jalr	94(ra) # 800037b6 <ilock>
    stati(f->ip, &st);
    80004760:	fb840593          	addi	a1,s0,-72
    80004764:	6c88                	ld	a0,24(s1)
    80004766:	fffff097          	auipc	ra,0xfffff
    8000476a:	2de080e7          	jalr	734(ra) # 80003a44 <stati>
    iunlock(f->ip);
    8000476e:	6c88                	ld	a0,24(s1)
    80004770:	fffff097          	auipc	ra,0xfffff
    80004774:	10c080e7          	jalr	268(ra) # 8000387c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004778:	46e1                	li	a3,24
    8000477a:	fb840613          	addi	a2,s0,-72
    8000477e:	85ce                	mv	a1,s3
    80004780:	05093503          	ld	a0,80(s2)
    80004784:	ffffd097          	auipc	ra,0xffffd
    80004788:	f66080e7          	jalr	-154(ra) # 800016ea <copyout>
    8000478c:	41f5551b          	sraiw	a0,a0,0x1f
    80004790:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004792:	60a6                	ld	ra,72(sp)
    80004794:	6406                	ld	s0,64(sp)
    80004796:	74e2                	ld	s1,56(sp)
    80004798:	79a2                	ld	s3,40(sp)
    8000479a:	6161                	addi	sp,sp,80
    8000479c:	8082                	ret
  return -1;
    8000479e:	557d                	li	a0,-1
    800047a0:	bfcd                	j	80004792 <filestat+0x62>

00000000800047a2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047a2:	7179                	addi	sp,sp,-48
    800047a4:	f406                	sd	ra,40(sp)
    800047a6:	f022                	sd	s0,32(sp)
    800047a8:	e84a                	sd	s2,16(sp)
    800047aa:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047ac:	00854783          	lbu	a5,8(a0)
    800047b0:	cbc5                	beqz	a5,80004860 <fileread+0xbe>
    800047b2:	ec26                	sd	s1,24(sp)
    800047b4:	e44e                	sd	s3,8(sp)
    800047b6:	84aa                	mv	s1,a0
    800047b8:	89ae                	mv	s3,a1
    800047ba:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800047bc:	411c                	lw	a5,0(a0)
    800047be:	4705                	li	a4,1
    800047c0:	04e78963          	beq	a5,a4,80004812 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047c4:	470d                	li	a4,3
    800047c6:	04e78f63          	beq	a5,a4,80004824 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800047ca:	4709                	li	a4,2
    800047cc:	08e79263          	bne	a5,a4,80004850 <fileread+0xae>
    ilock(f->ip);
    800047d0:	6d08                	ld	a0,24(a0)
    800047d2:	fffff097          	auipc	ra,0xfffff
    800047d6:	fe4080e7          	jalr	-28(ra) # 800037b6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047da:	874a                	mv	a4,s2
    800047dc:	5094                	lw	a3,32(s1)
    800047de:	864e                	mv	a2,s3
    800047e0:	4585                	li	a1,1
    800047e2:	6c88                	ld	a0,24(s1)
    800047e4:	fffff097          	auipc	ra,0xfffff
    800047e8:	28a080e7          	jalr	650(ra) # 80003a6e <readi>
    800047ec:	892a                	mv	s2,a0
    800047ee:	00a05563          	blez	a0,800047f8 <fileread+0x56>
      f->off += r;
    800047f2:	509c                	lw	a5,32(s1)
    800047f4:	9fa9                	addw	a5,a5,a0
    800047f6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047f8:	6c88                	ld	a0,24(s1)
    800047fa:	fffff097          	auipc	ra,0xfffff
    800047fe:	082080e7          	jalr	130(ra) # 8000387c <iunlock>
    80004802:	64e2                	ld	s1,24(sp)
    80004804:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004806:	854a                	mv	a0,s2
    80004808:	70a2                	ld	ra,40(sp)
    8000480a:	7402                	ld	s0,32(sp)
    8000480c:	6942                	ld	s2,16(sp)
    8000480e:	6145                	addi	sp,sp,48
    80004810:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004812:	6908                	ld	a0,16(a0)
    80004814:	00000097          	auipc	ra,0x0
    80004818:	400080e7          	jalr	1024(ra) # 80004c14 <piperead>
    8000481c:	892a                	mv	s2,a0
    8000481e:	64e2                	ld	s1,24(sp)
    80004820:	69a2                	ld	s3,8(sp)
    80004822:	b7d5                	j	80004806 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004824:	02451783          	lh	a5,36(a0)
    80004828:	03079693          	slli	a3,a5,0x30
    8000482c:	92c1                	srli	a3,a3,0x30
    8000482e:	4725                	li	a4,9
    80004830:	02d76a63          	bltu	a4,a3,80004864 <fileread+0xc2>
    80004834:	0792                	slli	a5,a5,0x4
    80004836:	0001f717          	auipc	a4,0x1f
    8000483a:	ea270713          	addi	a4,a4,-350 # 800236d8 <devsw>
    8000483e:	97ba                	add	a5,a5,a4
    80004840:	639c                	ld	a5,0(a5)
    80004842:	c78d                	beqz	a5,8000486c <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004844:	4505                	li	a0,1
    80004846:	9782                	jalr	a5
    80004848:	892a                	mv	s2,a0
    8000484a:	64e2                	ld	s1,24(sp)
    8000484c:	69a2                	ld	s3,8(sp)
    8000484e:	bf65                	j	80004806 <fileread+0x64>
    panic("fileread");
    80004850:	00004517          	auipc	a0,0x4
    80004854:	d4050513          	addi	a0,a0,-704 # 80008590 <etext+0x590>
    80004858:	ffffc097          	auipc	ra,0xffffc
    8000485c:	d08080e7          	jalr	-760(ra) # 80000560 <panic>
    return -1;
    80004860:	597d                	li	s2,-1
    80004862:	b755                	j	80004806 <fileread+0x64>
      return -1;
    80004864:	597d                	li	s2,-1
    80004866:	64e2                	ld	s1,24(sp)
    80004868:	69a2                	ld	s3,8(sp)
    8000486a:	bf71                	j	80004806 <fileread+0x64>
    8000486c:	597d                	li	s2,-1
    8000486e:	64e2                	ld	s1,24(sp)
    80004870:	69a2                	ld	s3,8(sp)
    80004872:	bf51                	j	80004806 <fileread+0x64>

0000000080004874 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004874:	00954783          	lbu	a5,9(a0)
    80004878:	12078963          	beqz	a5,800049aa <filewrite+0x136>
{
    8000487c:	715d                	addi	sp,sp,-80
    8000487e:	e486                	sd	ra,72(sp)
    80004880:	e0a2                	sd	s0,64(sp)
    80004882:	f84a                	sd	s2,48(sp)
    80004884:	f052                	sd	s4,32(sp)
    80004886:	e85a                	sd	s6,16(sp)
    80004888:	0880                	addi	s0,sp,80
    8000488a:	892a                	mv	s2,a0
    8000488c:	8b2e                	mv	s6,a1
    8000488e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004890:	411c                	lw	a5,0(a0)
    80004892:	4705                	li	a4,1
    80004894:	02e78763          	beq	a5,a4,800048c2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004898:	470d                	li	a4,3
    8000489a:	02e78a63          	beq	a5,a4,800048ce <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000489e:	4709                	li	a4,2
    800048a0:	0ee79863          	bne	a5,a4,80004990 <filewrite+0x11c>
    800048a4:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048a6:	0cc05463          	blez	a2,8000496e <filewrite+0xfa>
    800048aa:	fc26                	sd	s1,56(sp)
    800048ac:	ec56                	sd	s5,24(sp)
    800048ae:	e45e                	sd	s7,8(sp)
    800048b0:	e062                	sd	s8,0(sp)
    int i = 0;
    800048b2:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800048b4:	6b85                	lui	s7,0x1
    800048b6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800048ba:	6c05                	lui	s8,0x1
    800048bc:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800048c0:	a851                	j	80004954 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800048c2:	6908                	ld	a0,16(a0)
    800048c4:	00000097          	auipc	ra,0x0
    800048c8:	248080e7          	jalr	584(ra) # 80004b0c <pipewrite>
    800048cc:	a85d                	j	80004982 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048ce:	02451783          	lh	a5,36(a0)
    800048d2:	03079693          	slli	a3,a5,0x30
    800048d6:	92c1                	srli	a3,a3,0x30
    800048d8:	4725                	li	a4,9
    800048da:	0cd76a63          	bltu	a4,a3,800049ae <filewrite+0x13a>
    800048de:	0792                	slli	a5,a5,0x4
    800048e0:	0001f717          	auipc	a4,0x1f
    800048e4:	df870713          	addi	a4,a4,-520 # 800236d8 <devsw>
    800048e8:	97ba                	add	a5,a5,a4
    800048ea:	679c                	ld	a5,8(a5)
    800048ec:	c3f9                	beqz	a5,800049b2 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    800048ee:	4505                	li	a0,1
    800048f0:	9782                	jalr	a5
    800048f2:	a841                	j	80004982 <filewrite+0x10e>
      if(n1 > max)
    800048f4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800048f8:	00000097          	auipc	ra,0x0
    800048fc:	88c080e7          	jalr	-1908(ra) # 80004184 <begin_op>
      ilock(f->ip);
    80004900:	01893503          	ld	a0,24(s2)
    80004904:	fffff097          	auipc	ra,0xfffff
    80004908:	eb2080e7          	jalr	-334(ra) # 800037b6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000490c:	8756                	mv	a4,s5
    8000490e:	02092683          	lw	a3,32(s2)
    80004912:	01698633          	add	a2,s3,s6
    80004916:	4585                	li	a1,1
    80004918:	01893503          	ld	a0,24(s2)
    8000491c:	fffff097          	auipc	ra,0xfffff
    80004920:	262080e7          	jalr	610(ra) # 80003b7e <writei>
    80004924:	84aa                	mv	s1,a0
    80004926:	00a05763          	blez	a0,80004934 <filewrite+0xc0>
        f->off += r;
    8000492a:	02092783          	lw	a5,32(s2)
    8000492e:	9fa9                	addw	a5,a5,a0
    80004930:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004934:	01893503          	ld	a0,24(s2)
    80004938:	fffff097          	auipc	ra,0xfffff
    8000493c:	f44080e7          	jalr	-188(ra) # 8000387c <iunlock>
      end_op();
    80004940:	00000097          	auipc	ra,0x0
    80004944:	8be080e7          	jalr	-1858(ra) # 800041fe <end_op>

      if(r != n1){
    80004948:	029a9563          	bne	s5,s1,80004972 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    8000494c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004950:	0149da63          	bge	s3,s4,80004964 <filewrite+0xf0>
      int n1 = n - i;
    80004954:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004958:	0004879b          	sext.w	a5,s1
    8000495c:	f8fbdce3          	bge	s7,a5,800048f4 <filewrite+0x80>
    80004960:	84e2                	mv	s1,s8
    80004962:	bf49                	j	800048f4 <filewrite+0x80>
    80004964:	74e2                	ld	s1,56(sp)
    80004966:	6ae2                	ld	s5,24(sp)
    80004968:	6ba2                	ld	s7,8(sp)
    8000496a:	6c02                	ld	s8,0(sp)
    8000496c:	a039                	j	8000497a <filewrite+0x106>
    int i = 0;
    8000496e:	4981                	li	s3,0
    80004970:	a029                	j	8000497a <filewrite+0x106>
    80004972:	74e2                	ld	s1,56(sp)
    80004974:	6ae2                	ld	s5,24(sp)
    80004976:	6ba2                	ld	s7,8(sp)
    80004978:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000497a:	033a1e63          	bne	s4,s3,800049b6 <filewrite+0x142>
    8000497e:	8552                	mv	a0,s4
    80004980:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004982:	60a6                	ld	ra,72(sp)
    80004984:	6406                	ld	s0,64(sp)
    80004986:	7942                	ld	s2,48(sp)
    80004988:	7a02                	ld	s4,32(sp)
    8000498a:	6b42                	ld	s6,16(sp)
    8000498c:	6161                	addi	sp,sp,80
    8000498e:	8082                	ret
    80004990:	fc26                	sd	s1,56(sp)
    80004992:	f44e                	sd	s3,40(sp)
    80004994:	ec56                	sd	s5,24(sp)
    80004996:	e45e                	sd	s7,8(sp)
    80004998:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000499a:	00004517          	auipc	a0,0x4
    8000499e:	c0650513          	addi	a0,a0,-1018 # 800085a0 <etext+0x5a0>
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	bbe080e7          	jalr	-1090(ra) # 80000560 <panic>
    return -1;
    800049aa:	557d                	li	a0,-1
}
    800049ac:	8082                	ret
      return -1;
    800049ae:	557d                	li	a0,-1
    800049b0:	bfc9                	j	80004982 <filewrite+0x10e>
    800049b2:	557d                	li	a0,-1
    800049b4:	b7f9                	j	80004982 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    800049b6:	557d                	li	a0,-1
    800049b8:	79a2                	ld	s3,40(sp)
    800049ba:	b7e1                	j	80004982 <filewrite+0x10e>

00000000800049bc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049bc:	7179                	addi	sp,sp,-48
    800049be:	f406                	sd	ra,40(sp)
    800049c0:	f022                	sd	s0,32(sp)
    800049c2:	ec26                	sd	s1,24(sp)
    800049c4:	e052                	sd	s4,0(sp)
    800049c6:	1800                	addi	s0,sp,48
    800049c8:	84aa                	mv	s1,a0
    800049ca:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049cc:	0005b023          	sd	zero,0(a1)
    800049d0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	bbe080e7          	jalr	-1090(ra) # 80004592 <filealloc>
    800049dc:	e088                	sd	a0,0(s1)
    800049de:	cd49                	beqz	a0,80004a78 <pipealloc+0xbc>
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	bb2080e7          	jalr	-1102(ra) # 80004592 <filealloc>
    800049e8:	00aa3023          	sd	a0,0(s4)
    800049ec:	c141                	beqz	a0,80004a6c <pipealloc+0xb0>
    800049ee:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	158080e7          	jalr	344(ra) # 80000b48 <kalloc>
    800049f8:	892a                	mv	s2,a0
    800049fa:	c13d                	beqz	a0,80004a60 <pipealloc+0xa4>
    800049fc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800049fe:	4985                	li	s3,1
    80004a00:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a04:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a08:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a0c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a10:	00004597          	auipc	a1,0x4
    80004a14:	ba058593          	addi	a1,a1,-1120 # 800085b0 <etext+0x5b0>
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	190080e7          	jalr	400(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004a20:	609c                	ld	a5,0(s1)
    80004a22:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a26:	609c                	ld	a5,0(s1)
    80004a28:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a2c:	609c                	ld	a5,0(s1)
    80004a2e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a32:	609c                	ld	a5,0(s1)
    80004a34:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a38:	000a3783          	ld	a5,0(s4)
    80004a3c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a40:	000a3783          	ld	a5,0(s4)
    80004a44:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a48:	000a3783          	ld	a5,0(s4)
    80004a4c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a50:	000a3783          	ld	a5,0(s4)
    80004a54:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a58:	4501                	li	a0,0
    80004a5a:	6942                	ld	s2,16(sp)
    80004a5c:	69a2                	ld	s3,8(sp)
    80004a5e:	a03d                	j	80004a8c <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a60:	6088                	ld	a0,0(s1)
    80004a62:	c119                	beqz	a0,80004a68 <pipealloc+0xac>
    80004a64:	6942                	ld	s2,16(sp)
    80004a66:	a029                	j	80004a70 <pipealloc+0xb4>
    80004a68:	6942                	ld	s2,16(sp)
    80004a6a:	a039                	j	80004a78 <pipealloc+0xbc>
    80004a6c:	6088                	ld	a0,0(s1)
    80004a6e:	c50d                	beqz	a0,80004a98 <pipealloc+0xdc>
    fileclose(*f0);
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	bde080e7          	jalr	-1058(ra) # 8000464e <fileclose>
  if(*f1)
    80004a78:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a7c:	557d                	li	a0,-1
  if(*f1)
    80004a7e:	c799                	beqz	a5,80004a8c <pipealloc+0xd0>
    fileclose(*f1);
    80004a80:	853e                	mv	a0,a5
    80004a82:	00000097          	auipc	ra,0x0
    80004a86:	bcc080e7          	jalr	-1076(ra) # 8000464e <fileclose>
  return -1;
    80004a8a:	557d                	li	a0,-1
}
    80004a8c:	70a2                	ld	ra,40(sp)
    80004a8e:	7402                	ld	s0,32(sp)
    80004a90:	64e2                	ld	s1,24(sp)
    80004a92:	6a02                	ld	s4,0(sp)
    80004a94:	6145                	addi	sp,sp,48
    80004a96:	8082                	ret
  return -1;
    80004a98:	557d                	li	a0,-1
    80004a9a:	bfcd                	j	80004a8c <pipealloc+0xd0>

0000000080004a9c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a9c:	1101                	addi	sp,sp,-32
    80004a9e:	ec06                	sd	ra,24(sp)
    80004aa0:	e822                	sd	s0,16(sp)
    80004aa2:	e426                	sd	s1,8(sp)
    80004aa4:	e04a                	sd	s2,0(sp)
    80004aa6:	1000                	addi	s0,sp,32
    80004aa8:	84aa                	mv	s1,a0
    80004aaa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	18c080e7          	jalr	396(ra) # 80000c38 <acquire>
  if(writable){
    80004ab4:	02090d63          	beqz	s2,80004aee <pipeclose+0x52>
    pi->writeopen = 0;
    80004ab8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004abc:	21848513          	addi	a0,s1,536
    80004ac0:	ffffd097          	auipc	ra,0xffffd
    80004ac4:	6a0080e7          	jalr	1696(ra) # 80002160 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ac8:	2204b783          	ld	a5,544(s1)
    80004acc:	eb95                	bnez	a5,80004b00 <pipeclose+0x64>
    release(&pi->lock);
    80004ace:	8526                	mv	a0,s1
    80004ad0:	ffffc097          	auipc	ra,0xffffc
    80004ad4:	21c080e7          	jalr	540(ra) # 80000cec <release>
    kfree((char*)pi);
    80004ad8:	8526                	mv	a0,s1
    80004ada:	ffffc097          	auipc	ra,0xffffc
    80004ade:	f70080e7          	jalr	-144(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004ae2:	60e2                	ld	ra,24(sp)
    80004ae4:	6442                	ld	s0,16(sp)
    80004ae6:	64a2                	ld	s1,8(sp)
    80004ae8:	6902                	ld	s2,0(sp)
    80004aea:	6105                	addi	sp,sp,32
    80004aec:	8082                	ret
    pi->readopen = 0;
    80004aee:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004af2:	21c48513          	addi	a0,s1,540
    80004af6:	ffffd097          	auipc	ra,0xffffd
    80004afa:	66a080e7          	jalr	1642(ra) # 80002160 <wakeup>
    80004afe:	b7e9                	j	80004ac8 <pipeclose+0x2c>
    release(&pi->lock);
    80004b00:	8526                	mv	a0,s1
    80004b02:	ffffc097          	auipc	ra,0xffffc
    80004b06:	1ea080e7          	jalr	490(ra) # 80000cec <release>
}
    80004b0a:	bfe1                	j	80004ae2 <pipeclose+0x46>

0000000080004b0c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b0c:	711d                	addi	sp,sp,-96
    80004b0e:	ec86                	sd	ra,88(sp)
    80004b10:	e8a2                	sd	s0,80(sp)
    80004b12:	e4a6                	sd	s1,72(sp)
    80004b14:	e0ca                	sd	s2,64(sp)
    80004b16:	fc4e                	sd	s3,56(sp)
    80004b18:	f852                	sd	s4,48(sp)
    80004b1a:	f456                	sd	s5,40(sp)
    80004b1c:	1080                	addi	s0,sp,96
    80004b1e:	84aa                	mv	s1,a0
    80004b20:	8aae                	mv	s5,a1
    80004b22:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b24:	ffffd097          	auipc	ra,0xffffd
    80004b28:	f2e080e7          	jalr	-210(ra) # 80001a52 <myproc>
    80004b2c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b2e:	8526                	mv	a0,s1
    80004b30:	ffffc097          	auipc	ra,0xffffc
    80004b34:	108080e7          	jalr	264(ra) # 80000c38 <acquire>
  while(i < n){
    80004b38:	0d405863          	blez	s4,80004c08 <pipewrite+0xfc>
    80004b3c:	f05a                	sd	s6,32(sp)
    80004b3e:	ec5e                	sd	s7,24(sp)
    80004b40:	e862                	sd	s8,16(sp)
  int i = 0;
    80004b42:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b44:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b46:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b4a:	21c48b93          	addi	s7,s1,540
    80004b4e:	a089                	j	80004b90 <pipewrite+0x84>
      release(&pi->lock);
    80004b50:	8526                	mv	a0,s1
    80004b52:	ffffc097          	auipc	ra,0xffffc
    80004b56:	19a080e7          	jalr	410(ra) # 80000cec <release>
      return -1;
    80004b5a:	597d                	li	s2,-1
    80004b5c:	7b02                	ld	s6,32(sp)
    80004b5e:	6be2                	ld	s7,24(sp)
    80004b60:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b62:	854a                	mv	a0,s2
    80004b64:	60e6                	ld	ra,88(sp)
    80004b66:	6446                	ld	s0,80(sp)
    80004b68:	64a6                	ld	s1,72(sp)
    80004b6a:	6906                	ld	s2,64(sp)
    80004b6c:	79e2                	ld	s3,56(sp)
    80004b6e:	7a42                	ld	s4,48(sp)
    80004b70:	7aa2                	ld	s5,40(sp)
    80004b72:	6125                	addi	sp,sp,96
    80004b74:	8082                	ret
      wakeup(&pi->nread);
    80004b76:	8562                	mv	a0,s8
    80004b78:	ffffd097          	auipc	ra,0xffffd
    80004b7c:	5e8080e7          	jalr	1512(ra) # 80002160 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b80:	85a6                	mv	a1,s1
    80004b82:	855e                	mv	a0,s7
    80004b84:	ffffd097          	auipc	ra,0xffffd
    80004b88:	578080e7          	jalr	1400(ra) # 800020fc <sleep>
  while(i < n){
    80004b8c:	05495f63          	bge	s2,s4,80004bea <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004b90:	2204a783          	lw	a5,544(s1)
    80004b94:	dfd5                	beqz	a5,80004b50 <pipewrite+0x44>
    80004b96:	854e                	mv	a0,s3
    80004b98:	ffffe097          	auipc	ra,0xffffe
    80004b9c:	80c080e7          	jalr	-2036(ra) # 800023a4 <killed>
    80004ba0:	f945                	bnez	a0,80004b50 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ba2:	2184a783          	lw	a5,536(s1)
    80004ba6:	21c4a703          	lw	a4,540(s1)
    80004baa:	2007879b          	addiw	a5,a5,512
    80004bae:	fcf704e3          	beq	a4,a5,80004b76 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bb2:	4685                	li	a3,1
    80004bb4:	01590633          	add	a2,s2,s5
    80004bb8:	faf40593          	addi	a1,s0,-81
    80004bbc:	0509b503          	ld	a0,80(s3)
    80004bc0:	ffffd097          	auipc	ra,0xffffd
    80004bc4:	bb6080e7          	jalr	-1098(ra) # 80001776 <copyin>
    80004bc8:	05650263          	beq	a0,s6,80004c0c <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bcc:	21c4a783          	lw	a5,540(s1)
    80004bd0:	0017871b          	addiw	a4,a5,1
    80004bd4:	20e4ae23          	sw	a4,540(s1)
    80004bd8:	1ff7f793          	andi	a5,a5,511
    80004bdc:	97a6                	add	a5,a5,s1
    80004bde:	faf44703          	lbu	a4,-81(s0)
    80004be2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004be6:	2905                	addiw	s2,s2,1
    80004be8:	b755                	j	80004b8c <pipewrite+0x80>
    80004bea:	7b02                	ld	s6,32(sp)
    80004bec:	6be2                	ld	s7,24(sp)
    80004bee:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004bf0:	21848513          	addi	a0,s1,536
    80004bf4:	ffffd097          	auipc	ra,0xffffd
    80004bf8:	56c080e7          	jalr	1388(ra) # 80002160 <wakeup>
  release(&pi->lock);
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	0ee080e7          	jalr	238(ra) # 80000cec <release>
  return i;
    80004c06:	bfb1                	j	80004b62 <pipewrite+0x56>
  int i = 0;
    80004c08:	4901                	li	s2,0
    80004c0a:	b7dd                	j	80004bf0 <pipewrite+0xe4>
    80004c0c:	7b02                	ld	s6,32(sp)
    80004c0e:	6be2                	ld	s7,24(sp)
    80004c10:	6c42                	ld	s8,16(sp)
    80004c12:	bff9                	j	80004bf0 <pipewrite+0xe4>

0000000080004c14 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c14:	715d                	addi	sp,sp,-80
    80004c16:	e486                	sd	ra,72(sp)
    80004c18:	e0a2                	sd	s0,64(sp)
    80004c1a:	fc26                	sd	s1,56(sp)
    80004c1c:	f84a                	sd	s2,48(sp)
    80004c1e:	f44e                	sd	s3,40(sp)
    80004c20:	f052                	sd	s4,32(sp)
    80004c22:	ec56                	sd	s5,24(sp)
    80004c24:	0880                	addi	s0,sp,80
    80004c26:	84aa                	mv	s1,a0
    80004c28:	892e                	mv	s2,a1
    80004c2a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c2c:	ffffd097          	auipc	ra,0xffffd
    80004c30:	e26080e7          	jalr	-474(ra) # 80001a52 <myproc>
    80004c34:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c36:	8526                	mv	a0,s1
    80004c38:	ffffc097          	auipc	ra,0xffffc
    80004c3c:	000080e7          	jalr	ra # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c40:	2184a703          	lw	a4,536(s1)
    80004c44:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c48:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c4c:	02f71963          	bne	a4,a5,80004c7e <piperead+0x6a>
    80004c50:	2244a783          	lw	a5,548(s1)
    80004c54:	cf95                	beqz	a5,80004c90 <piperead+0x7c>
    if(killed(pr)){
    80004c56:	8552                	mv	a0,s4
    80004c58:	ffffd097          	auipc	ra,0xffffd
    80004c5c:	74c080e7          	jalr	1868(ra) # 800023a4 <killed>
    80004c60:	e10d                	bnez	a0,80004c82 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c62:	85a6                	mv	a1,s1
    80004c64:	854e                	mv	a0,s3
    80004c66:	ffffd097          	auipc	ra,0xffffd
    80004c6a:	496080e7          	jalr	1174(ra) # 800020fc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c6e:	2184a703          	lw	a4,536(s1)
    80004c72:	21c4a783          	lw	a5,540(s1)
    80004c76:	fcf70de3          	beq	a4,a5,80004c50 <piperead+0x3c>
    80004c7a:	e85a                	sd	s6,16(sp)
    80004c7c:	a819                	j	80004c92 <piperead+0x7e>
    80004c7e:	e85a                	sd	s6,16(sp)
    80004c80:	a809                	j	80004c92 <piperead+0x7e>
      release(&pi->lock);
    80004c82:	8526                	mv	a0,s1
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	068080e7          	jalr	104(ra) # 80000cec <release>
      return -1;
    80004c8c:	59fd                	li	s3,-1
    80004c8e:	a0a5                	j	80004cf6 <piperead+0xe2>
    80004c90:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c92:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c94:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c96:	05505463          	blez	s5,80004cde <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004c9a:	2184a783          	lw	a5,536(s1)
    80004c9e:	21c4a703          	lw	a4,540(s1)
    80004ca2:	02f70e63          	beq	a4,a5,80004cde <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ca6:	0017871b          	addiw	a4,a5,1
    80004caa:	20e4ac23          	sw	a4,536(s1)
    80004cae:	1ff7f793          	andi	a5,a5,511
    80004cb2:	97a6                	add	a5,a5,s1
    80004cb4:	0187c783          	lbu	a5,24(a5)
    80004cb8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cbc:	4685                	li	a3,1
    80004cbe:	fbf40613          	addi	a2,s0,-65
    80004cc2:	85ca                	mv	a1,s2
    80004cc4:	050a3503          	ld	a0,80(s4)
    80004cc8:	ffffd097          	auipc	ra,0xffffd
    80004ccc:	a22080e7          	jalr	-1502(ra) # 800016ea <copyout>
    80004cd0:	01650763          	beq	a0,s6,80004cde <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cd4:	2985                	addiw	s3,s3,1
    80004cd6:	0905                	addi	s2,s2,1
    80004cd8:	fd3a91e3          	bne	s5,s3,80004c9a <piperead+0x86>
    80004cdc:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004cde:	21c48513          	addi	a0,s1,540
    80004ce2:	ffffd097          	auipc	ra,0xffffd
    80004ce6:	47e080e7          	jalr	1150(ra) # 80002160 <wakeup>
  release(&pi->lock);
    80004cea:	8526                	mv	a0,s1
    80004cec:	ffffc097          	auipc	ra,0xffffc
    80004cf0:	000080e7          	jalr	ra # 80000cec <release>
    80004cf4:	6b42                	ld	s6,16(sp)
  return i;
}
    80004cf6:	854e                	mv	a0,s3
    80004cf8:	60a6                	ld	ra,72(sp)
    80004cfa:	6406                	ld	s0,64(sp)
    80004cfc:	74e2                	ld	s1,56(sp)
    80004cfe:	7942                	ld	s2,48(sp)
    80004d00:	79a2                	ld	s3,40(sp)
    80004d02:	7a02                	ld	s4,32(sp)
    80004d04:	6ae2                	ld	s5,24(sp)
    80004d06:	6161                	addi	sp,sp,80
    80004d08:	8082                	ret

0000000080004d0a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004d0a:	1141                	addi	sp,sp,-16
    80004d0c:	e422                	sd	s0,8(sp)
    80004d0e:	0800                	addi	s0,sp,16
    80004d10:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004d12:	8905                	andi	a0,a0,1
    80004d14:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004d16:	8b89                	andi	a5,a5,2
    80004d18:	c399                	beqz	a5,80004d1e <flags2perm+0x14>
      perm |= PTE_W;
    80004d1a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004d1e:	6422                	ld	s0,8(sp)
    80004d20:	0141                	addi	sp,sp,16
    80004d22:	8082                	ret

0000000080004d24 <exec>:

int
exec(char *path, char **argv)
{
    80004d24:	df010113          	addi	sp,sp,-528
    80004d28:	20113423          	sd	ra,520(sp)
    80004d2c:	20813023          	sd	s0,512(sp)
    80004d30:	ffa6                	sd	s1,504(sp)
    80004d32:	fbca                	sd	s2,496(sp)
    80004d34:	0c00                	addi	s0,sp,528
    80004d36:	892a                	mv	s2,a0
    80004d38:	dea43c23          	sd	a0,-520(s0)
    80004d3c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d40:	ffffd097          	auipc	ra,0xffffd
    80004d44:	d12080e7          	jalr	-750(ra) # 80001a52 <myproc>
    80004d48:	84aa                	mv	s1,a0

  begin_op();
    80004d4a:	fffff097          	auipc	ra,0xfffff
    80004d4e:	43a080e7          	jalr	1082(ra) # 80004184 <begin_op>

  if((ip = namei(path)) == 0){
    80004d52:	854a                	mv	a0,s2
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	230080e7          	jalr	560(ra) # 80003f84 <namei>
    80004d5c:	c135                	beqz	a0,80004dc0 <exec+0x9c>
    80004d5e:	f3d2                	sd	s4,480(sp)
    80004d60:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	a54080e7          	jalr	-1452(ra) # 800037b6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d6a:	04000713          	li	a4,64
    80004d6e:	4681                	li	a3,0
    80004d70:	e5040613          	addi	a2,s0,-432
    80004d74:	4581                	li	a1,0
    80004d76:	8552                	mv	a0,s4
    80004d78:	fffff097          	auipc	ra,0xfffff
    80004d7c:	cf6080e7          	jalr	-778(ra) # 80003a6e <readi>
    80004d80:	04000793          	li	a5,64
    80004d84:	00f51a63          	bne	a0,a5,80004d98 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004d88:	e5042703          	lw	a4,-432(s0)
    80004d8c:	464c47b7          	lui	a5,0x464c4
    80004d90:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d94:	02f70c63          	beq	a4,a5,80004dcc <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d98:	8552                	mv	a0,s4
    80004d9a:	fffff097          	auipc	ra,0xfffff
    80004d9e:	c82080e7          	jalr	-894(ra) # 80003a1c <iunlockput>
    end_op();
    80004da2:	fffff097          	auipc	ra,0xfffff
    80004da6:	45c080e7          	jalr	1116(ra) # 800041fe <end_op>
  }
  return -1;
    80004daa:	557d                	li	a0,-1
    80004dac:	7a1e                	ld	s4,480(sp)
}
    80004dae:	20813083          	ld	ra,520(sp)
    80004db2:	20013403          	ld	s0,512(sp)
    80004db6:	74fe                	ld	s1,504(sp)
    80004db8:	795e                	ld	s2,496(sp)
    80004dba:	21010113          	addi	sp,sp,528
    80004dbe:	8082                	ret
    end_op();
    80004dc0:	fffff097          	auipc	ra,0xfffff
    80004dc4:	43e080e7          	jalr	1086(ra) # 800041fe <end_op>
    return -1;
    80004dc8:	557d                	li	a0,-1
    80004dca:	b7d5                	j	80004dae <exec+0x8a>
    80004dcc:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004dce:	8526                	mv	a0,s1
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	d46080e7          	jalr	-698(ra) # 80001b16 <proc_pagetable>
    80004dd8:	8b2a                	mv	s6,a0
    80004dda:	30050f63          	beqz	a0,800050f8 <exec+0x3d4>
    80004dde:	f7ce                	sd	s3,488(sp)
    80004de0:	efd6                	sd	s5,472(sp)
    80004de2:	e7de                	sd	s7,456(sp)
    80004de4:	e3e2                	sd	s8,448(sp)
    80004de6:	ff66                	sd	s9,440(sp)
    80004de8:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dea:	e7042d03          	lw	s10,-400(s0)
    80004dee:	e8845783          	lhu	a5,-376(s0)
    80004df2:	14078d63          	beqz	a5,80004f4c <exec+0x228>
    80004df6:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004df8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dfa:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004dfc:	6c85                	lui	s9,0x1
    80004dfe:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e02:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004e06:	6a85                	lui	s5,0x1
    80004e08:	a0b5                	j	80004e74 <exec+0x150>
      panic("loadseg: address should exist");
    80004e0a:	00003517          	auipc	a0,0x3
    80004e0e:	7ae50513          	addi	a0,a0,1966 # 800085b8 <etext+0x5b8>
    80004e12:	ffffb097          	auipc	ra,0xffffb
    80004e16:	74e080e7          	jalr	1870(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80004e1a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e1c:	8726                	mv	a4,s1
    80004e1e:	012c06bb          	addw	a3,s8,s2
    80004e22:	4581                	li	a1,0
    80004e24:	8552                	mv	a0,s4
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	c48080e7          	jalr	-952(ra) # 80003a6e <readi>
    80004e2e:	2501                	sext.w	a0,a0
    80004e30:	28a49863          	bne	s1,a0,800050c0 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80004e34:	012a893b          	addw	s2,s5,s2
    80004e38:	03397563          	bgeu	s2,s3,80004e62 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004e3c:	02091593          	slli	a1,s2,0x20
    80004e40:	9181                	srli	a1,a1,0x20
    80004e42:	95de                	add	a1,a1,s7
    80004e44:	855a                	mv	a0,s6
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	278080e7          	jalr	632(ra) # 800010be <walkaddr>
    80004e4e:	862a                	mv	a2,a0
    if(pa == 0)
    80004e50:	dd4d                	beqz	a0,80004e0a <exec+0xe6>
    if(sz - i < PGSIZE)
    80004e52:	412984bb          	subw	s1,s3,s2
    80004e56:	0004879b          	sext.w	a5,s1
    80004e5a:	fcfcf0e3          	bgeu	s9,a5,80004e1a <exec+0xf6>
    80004e5e:	84d6                	mv	s1,s5
    80004e60:	bf6d                	j	80004e1a <exec+0xf6>
    sz = sz1;
    80004e62:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e66:	2d85                	addiw	s11,s11,1
    80004e68:	038d0d1b          	addiw	s10,s10,56
    80004e6c:	e8845783          	lhu	a5,-376(s0)
    80004e70:	08fdd663          	bge	s11,a5,80004efc <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e74:	2d01                	sext.w	s10,s10
    80004e76:	03800713          	li	a4,56
    80004e7a:	86ea                	mv	a3,s10
    80004e7c:	e1840613          	addi	a2,s0,-488
    80004e80:	4581                	li	a1,0
    80004e82:	8552                	mv	a0,s4
    80004e84:	fffff097          	auipc	ra,0xfffff
    80004e88:	bea080e7          	jalr	-1046(ra) # 80003a6e <readi>
    80004e8c:	03800793          	li	a5,56
    80004e90:	20f51063          	bne	a0,a5,80005090 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80004e94:	e1842783          	lw	a5,-488(s0)
    80004e98:	4705                	li	a4,1
    80004e9a:	fce796e3          	bne	a5,a4,80004e66 <exec+0x142>
    if(ph.memsz < ph.filesz)
    80004e9e:	e4043483          	ld	s1,-448(s0)
    80004ea2:	e3843783          	ld	a5,-456(s0)
    80004ea6:	1ef4e963          	bltu	s1,a5,80005098 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004eaa:	e2843783          	ld	a5,-472(s0)
    80004eae:	94be                	add	s1,s1,a5
    80004eb0:	1ef4e863          	bltu	s1,a5,800050a0 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    80004eb4:	df043703          	ld	a4,-528(s0)
    80004eb8:	8ff9                	and	a5,a5,a4
    80004eba:	1e079763          	bnez	a5,800050a8 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ebe:	e1c42503          	lw	a0,-484(s0)
    80004ec2:	00000097          	auipc	ra,0x0
    80004ec6:	e48080e7          	jalr	-440(ra) # 80004d0a <flags2perm>
    80004eca:	86aa                	mv	a3,a0
    80004ecc:	8626                	mv	a2,s1
    80004ece:	85ca                	mv	a1,s2
    80004ed0:	855a                	mv	a0,s6
    80004ed2:	ffffc097          	auipc	ra,0xffffc
    80004ed6:	5b0080e7          	jalr	1456(ra) # 80001482 <uvmalloc>
    80004eda:	e0a43423          	sd	a0,-504(s0)
    80004ede:	1c050963          	beqz	a0,800050b0 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ee2:	e2843b83          	ld	s7,-472(s0)
    80004ee6:	e2042c03          	lw	s8,-480(s0)
    80004eea:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004eee:	00098463          	beqz	s3,80004ef6 <exec+0x1d2>
    80004ef2:	4901                	li	s2,0
    80004ef4:	b7a1                	j	80004e3c <exec+0x118>
    sz = sz1;
    80004ef6:	e0843903          	ld	s2,-504(s0)
    80004efa:	b7b5                	j	80004e66 <exec+0x142>
    80004efc:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004efe:	8552                	mv	a0,s4
    80004f00:	fffff097          	auipc	ra,0xfffff
    80004f04:	b1c080e7          	jalr	-1252(ra) # 80003a1c <iunlockput>
  end_op();
    80004f08:	fffff097          	auipc	ra,0xfffff
    80004f0c:	2f6080e7          	jalr	758(ra) # 800041fe <end_op>
  p = myproc();
    80004f10:	ffffd097          	auipc	ra,0xffffd
    80004f14:	b42080e7          	jalr	-1214(ra) # 80001a52 <myproc>
    80004f18:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f1a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004f1e:	6985                	lui	s3,0x1
    80004f20:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004f22:	99ca                	add	s3,s3,s2
    80004f24:	77fd                	lui	a5,0xfffff
    80004f26:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f2a:	4691                	li	a3,4
    80004f2c:	6609                	lui	a2,0x2
    80004f2e:	964e                	add	a2,a2,s3
    80004f30:	85ce                	mv	a1,s3
    80004f32:	855a                	mv	a0,s6
    80004f34:	ffffc097          	auipc	ra,0xffffc
    80004f38:	54e080e7          	jalr	1358(ra) # 80001482 <uvmalloc>
    80004f3c:	892a                	mv	s2,a0
    80004f3e:	e0a43423          	sd	a0,-504(s0)
    80004f42:	e519                	bnez	a0,80004f50 <exec+0x22c>
  if(pagetable)
    80004f44:	e1343423          	sd	s3,-504(s0)
    80004f48:	4a01                	li	s4,0
    80004f4a:	aaa5                	j	800050c2 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f4c:	4901                	li	s2,0
    80004f4e:	bf45                	j	80004efe <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f50:	75f9                	lui	a1,0xffffe
    80004f52:	95aa                	add	a1,a1,a0
    80004f54:	855a                	mv	a0,s6
    80004f56:	ffffc097          	auipc	ra,0xffffc
    80004f5a:	762080e7          	jalr	1890(ra) # 800016b8 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f5e:	7bfd                	lui	s7,0xfffff
    80004f60:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004f62:	e0043783          	ld	a5,-512(s0)
    80004f66:	6388                	ld	a0,0(a5)
    80004f68:	c52d                	beqz	a0,80004fd2 <exec+0x2ae>
    80004f6a:	e9040993          	addi	s3,s0,-368
    80004f6e:	f9040c13          	addi	s8,s0,-112
    80004f72:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	f34080e7          	jalr	-204(ra) # 80000ea8 <strlen>
    80004f7c:	0015079b          	addiw	a5,a0,1
    80004f80:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f84:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004f88:	13796863          	bltu	s2,s7,800050b8 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f8c:	e0043d03          	ld	s10,-512(s0)
    80004f90:	000d3a03          	ld	s4,0(s10)
    80004f94:	8552                	mv	a0,s4
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	f12080e7          	jalr	-238(ra) # 80000ea8 <strlen>
    80004f9e:	0015069b          	addiw	a3,a0,1
    80004fa2:	8652                	mv	a2,s4
    80004fa4:	85ca                	mv	a1,s2
    80004fa6:	855a                	mv	a0,s6
    80004fa8:	ffffc097          	auipc	ra,0xffffc
    80004fac:	742080e7          	jalr	1858(ra) # 800016ea <copyout>
    80004fb0:	10054663          	bltz	a0,800050bc <exec+0x398>
    ustack[argc] = sp;
    80004fb4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fb8:	0485                	addi	s1,s1,1
    80004fba:	008d0793          	addi	a5,s10,8
    80004fbe:	e0f43023          	sd	a5,-512(s0)
    80004fc2:	008d3503          	ld	a0,8(s10)
    80004fc6:	c909                	beqz	a0,80004fd8 <exec+0x2b4>
    if(argc >= MAXARG)
    80004fc8:	09a1                	addi	s3,s3,8
    80004fca:	fb8995e3          	bne	s3,s8,80004f74 <exec+0x250>
  ip = 0;
    80004fce:	4a01                	li	s4,0
    80004fd0:	a8cd                	j	800050c2 <exec+0x39e>
  sp = sz;
    80004fd2:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004fd6:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fd8:	00349793          	slli	a5,s1,0x3
    80004fdc:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd8720>
    80004fe0:	97a2                	add	a5,a5,s0
    80004fe2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004fe6:	00148693          	addi	a3,s1,1
    80004fea:	068e                	slli	a3,a3,0x3
    80004fec:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ff0:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004ff4:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004ff8:	f57966e3          	bltu	s2,s7,80004f44 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ffc:	e9040613          	addi	a2,s0,-368
    80005000:	85ca                	mv	a1,s2
    80005002:	855a                	mv	a0,s6
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	6e6080e7          	jalr	1766(ra) # 800016ea <copyout>
    8000500c:	0e054863          	bltz	a0,800050fc <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005010:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005014:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005018:	df843783          	ld	a5,-520(s0)
    8000501c:	0007c703          	lbu	a4,0(a5)
    80005020:	cf11                	beqz	a4,8000503c <exec+0x318>
    80005022:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005024:	02f00693          	li	a3,47
    80005028:	a039                	j	80005036 <exec+0x312>
      last = s+1;
    8000502a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000502e:	0785                	addi	a5,a5,1
    80005030:	fff7c703          	lbu	a4,-1(a5)
    80005034:	c701                	beqz	a4,8000503c <exec+0x318>
    if(*s == '/')
    80005036:	fed71ce3          	bne	a4,a3,8000502e <exec+0x30a>
    8000503a:	bfc5                	j	8000502a <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    8000503c:	4641                	li	a2,16
    8000503e:	df843583          	ld	a1,-520(s0)
    80005042:	158a8513          	addi	a0,s5,344
    80005046:	ffffc097          	auipc	ra,0xffffc
    8000504a:	e30080e7          	jalr	-464(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    8000504e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005052:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005056:	e0843783          	ld	a5,-504(s0)
    8000505a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000505e:	058ab783          	ld	a5,88(s5)
    80005062:	e6843703          	ld	a4,-408(s0)
    80005066:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005068:	058ab783          	ld	a5,88(s5)
    8000506c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005070:	85e6                	mv	a1,s9
    80005072:	ffffd097          	auipc	ra,0xffffd
    80005076:	b40080e7          	jalr	-1216(ra) # 80001bb2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000507a:	0004851b          	sext.w	a0,s1
    8000507e:	79be                	ld	s3,488(sp)
    80005080:	7a1e                	ld	s4,480(sp)
    80005082:	6afe                	ld	s5,472(sp)
    80005084:	6b5e                	ld	s6,464(sp)
    80005086:	6bbe                	ld	s7,456(sp)
    80005088:	6c1e                	ld	s8,448(sp)
    8000508a:	7cfa                	ld	s9,440(sp)
    8000508c:	7d5a                	ld	s10,432(sp)
    8000508e:	b305                	j	80004dae <exec+0x8a>
    80005090:	e1243423          	sd	s2,-504(s0)
    80005094:	7dba                	ld	s11,424(sp)
    80005096:	a035                	j	800050c2 <exec+0x39e>
    80005098:	e1243423          	sd	s2,-504(s0)
    8000509c:	7dba                	ld	s11,424(sp)
    8000509e:	a015                	j	800050c2 <exec+0x39e>
    800050a0:	e1243423          	sd	s2,-504(s0)
    800050a4:	7dba                	ld	s11,424(sp)
    800050a6:	a831                	j	800050c2 <exec+0x39e>
    800050a8:	e1243423          	sd	s2,-504(s0)
    800050ac:	7dba                	ld	s11,424(sp)
    800050ae:	a811                	j	800050c2 <exec+0x39e>
    800050b0:	e1243423          	sd	s2,-504(s0)
    800050b4:	7dba                	ld	s11,424(sp)
    800050b6:	a031                	j	800050c2 <exec+0x39e>
  ip = 0;
    800050b8:	4a01                	li	s4,0
    800050ba:	a021                	j	800050c2 <exec+0x39e>
    800050bc:	4a01                	li	s4,0
  if(pagetable)
    800050be:	a011                	j	800050c2 <exec+0x39e>
    800050c0:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800050c2:	e0843583          	ld	a1,-504(s0)
    800050c6:	855a                	mv	a0,s6
    800050c8:	ffffd097          	auipc	ra,0xffffd
    800050cc:	aea080e7          	jalr	-1302(ra) # 80001bb2 <proc_freepagetable>
  return -1;
    800050d0:	557d                	li	a0,-1
  if(ip){
    800050d2:	000a1b63          	bnez	s4,800050e8 <exec+0x3c4>
    800050d6:	79be                	ld	s3,488(sp)
    800050d8:	7a1e                	ld	s4,480(sp)
    800050da:	6afe                	ld	s5,472(sp)
    800050dc:	6b5e                	ld	s6,464(sp)
    800050de:	6bbe                	ld	s7,456(sp)
    800050e0:	6c1e                	ld	s8,448(sp)
    800050e2:	7cfa                	ld	s9,440(sp)
    800050e4:	7d5a                	ld	s10,432(sp)
    800050e6:	b1e1                	j	80004dae <exec+0x8a>
    800050e8:	79be                	ld	s3,488(sp)
    800050ea:	6afe                	ld	s5,472(sp)
    800050ec:	6b5e                	ld	s6,464(sp)
    800050ee:	6bbe                	ld	s7,456(sp)
    800050f0:	6c1e                	ld	s8,448(sp)
    800050f2:	7cfa                	ld	s9,440(sp)
    800050f4:	7d5a                	ld	s10,432(sp)
    800050f6:	b14d                	j	80004d98 <exec+0x74>
    800050f8:	6b5e                	ld	s6,464(sp)
    800050fa:	b979                	j	80004d98 <exec+0x74>
  sz = sz1;
    800050fc:	e0843983          	ld	s3,-504(s0)
    80005100:	b591                	j	80004f44 <exec+0x220>

0000000080005102 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005102:	7179                	addi	sp,sp,-48
    80005104:	f406                	sd	ra,40(sp)
    80005106:	f022                	sd	s0,32(sp)
    80005108:	ec26                	sd	s1,24(sp)
    8000510a:	e84a                	sd	s2,16(sp)
    8000510c:	1800                	addi	s0,sp,48
    8000510e:	892e                	mv	s2,a1
    80005110:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005112:	fdc40593          	addi	a1,s0,-36
    80005116:	ffffe097          	auipc	ra,0xffffe
    8000511a:	a5c080e7          	jalr	-1444(ra) # 80002b72 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000511e:	fdc42703          	lw	a4,-36(s0)
    80005122:	47bd                	li	a5,15
    80005124:	02e7eb63          	bltu	a5,a4,8000515a <argfd+0x58>
    80005128:	ffffd097          	auipc	ra,0xffffd
    8000512c:	92a080e7          	jalr	-1750(ra) # 80001a52 <myproc>
    80005130:	fdc42703          	lw	a4,-36(s0)
    80005134:	01a70793          	addi	a5,a4,26
    80005138:	078e                	slli	a5,a5,0x3
    8000513a:	953e                	add	a0,a0,a5
    8000513c:	611c                	ld	a5,0(a0)
    8000513e:	c385                	beqz	a5,8000515e <argfd+0x5c>
    return -1;
  if(pfd)
    80005140:	00090463          	beqz	s2,80005148 <argfd+0x46>
    *pfd = fd;
    80005144:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005148:	4501                	li	a0,0
  if(pf)
    8000514a:	c091                	beqz	s1,8000514e <argfd+0x4c>
    *pf = f;
    8000514c:	e09c                	sd	a5,0(s1)
}
    8000514e:	70a2                	ld	ra,40(sp)
    80005150:	7402                	ld	s0,32(sp)
    80005152:	64e2                	ld	s1,24(sp)
    80005154:	6942                	ld	s2,16(sp)
    80005156:	6145                	addi	sp,sp,48
    80005158:	8082                	ret
    return -1;
    8000515a:	557d                	li	a0,-1
    8000515c:	bfcd                	j	8000514e <argfd+0x4c>
    8000515e:	557d                	li	a0,-1
    80005160:	b7fd                	j	8000514e <argfd+0x4c>

0000000080005162 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005162:	1101                	addi	sp,sp,-32
    80005164:	ec06                	sd	ra,24(sp)
    80005166:	e822                	sd	s0,16(sp)
    80005168:	e426                	sd	s1,8(sp)
    8000516a:	1000                	addi	s0,sp,32
    8000516c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000516e:	ffffd097          	auipc	ra,0xffffd
    80005172:	8e4080e7          	jalr	-1820(ra) # 80001a52 <myproc>
    80005176:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005178:	0d050793          	addi	a5,a0,208
    8000517c:	4501                	li	a0,0
    8000517e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005180:	6398                	ld	a4,0(a5)
    80005182:	cb19                	beqz	a4,80005198 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005184:	2505                	addiw	a0,a0,1
    80005186:	07a1                	addi	a5,a5,8
    80005188:	fed51ce3          	bne	a0,a3,80005180 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000518c:	557d                	li	a0,-1
}
    8000518e:	60e2                	ld	ra,24(sp)
    80005190:	6442                	ld	s0,16(sp)
    80005192:	64a2                	ld	s1,8(sp)
    80005194:	6105                	addi	sp,sp,32
    80005196:	8082                	ret
      p->ofile[fd] = f;
    80005198:	01a50793          	addi	a5,a0,26
    8000519c:	078e                	slli	a5,a5,0x3
    8000519e:	963e                	add	a2,a2,a5
    800051a0:	e204                	sd	s1,0(a2)
      return fd;
    800051a2:	b7f5                	j	8000518e <fdalloc+0x2c>

00000000800051a4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051a4:	715d                	addi	sp,sp,-80
    800051a6:	e486                	sd	ra,72(sp)
    800051a8:	e0a2                	sd	s0,64(sp)
    800051aa:	fc26                	sd	s1,56(sp)
    800051ac:	f84a                	sd	s2,48(sp)
    800051ae:	f44e                	sd	s3,40(sp)
    800051b0:	ec56                	sd	s5,24(sp)
    800051b2:	e85a                	sd	s6,16(sp)
    800051b4:	0880                	addi	s0,sp,80
    800051b6:	8b2e                	mv	s6,a1
    800051b8:	89b2                	mv	s3,a2
    800051ba:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051bc:	fb040593          	addi	a1,s0,-80
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	de2080e7          	jalr	-542(ra) # 80003fa2 <nameiparent>
    800051c8:	84aa                	mv	s1,a0
    800051ca:	14050e63          	beqz	a0,80005326 <create+0x182>
    return 0;

  ilock(dp);
    800051ce:	ffffe097          	auipc	ra,0xffffe
    800051d2:	5e8080e7          	jalr	1512(ra) # 800037b6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051d6:	4601                	li	a2,0
    800051d8:	fb040593          	addi	a1,s0,-80
    800051dc:	8526                	mv	a0,s1
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	ae4080e7          	jalr	-1308(ra) # 80003cc2 <dirlookup>
    800051e6:	8aaa                	mv	s5,a0
    800051e8:	c539                	beqz	a0,80005236 <create+0x92>
    iunlockput(dp);
    800051ea:	8526                	mv	a0,s1
    800051ec:	fffff097          	auipc	ra,0xfffff
    800051f0:	830080e7          	jalr	-2000(ra) # 80003a1c <iunlockput>
    ilock(ip);
    800051f4:	8556                	mv	a0,s5
    800051f6:	ffffe097          	auipc	ra,0xffffe
    800051fa:	5c0080e7          	jalr	1472(ra) # 800037b6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051fe:	4789                	li	a5,2
    80005200:	02fb1463          	bne	s6,a5,80005228 <create+0x84>
    80005204:	044ad783          	lhu	a5,68(s5)
    80005208:	37f9                	addiw	a5,a5,-2
    8000520a:	17c2                	slli	a5,a5,0x30
    8000520c:	93c1                	srli	a5,a5,0x30
    8000520e:	4705                	li	a4,1
    80005210:	00f76c63          	bltu	a4,a5,80005228 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005214:	8556                	mv	a0,s5
    80005216:	60a6                	ld	ra,72(sp)
    80005218:	6406                	ld	s0,64(sp)
    8000521a:	74e2                	ld	s1,56(sp)
    8000521c:	7942                	ld	s2,48(sp)
    8000521e:	79a2                	ld	s3,40(sp)
    80005220:	6ae2                	ld	s5,24(sp)
    80005222:	6b42                	ld	s6,16(sp)
    80005224:	6161                	addi	sp,sp,80
    80005226:	8082                	ret
    iunlockput(ip);
    80005228:	8556                	mv	a0,s5
    8000522a:	ffffe097          	auipc	ra,0xffffe
    8000522e:	7f2080e7          	jalr	2034(ra) # 80003a1c <iunlockput>
    return 0;
    80005232:	4a81                	li	s5,0
    80005234:	b7c5                	j	80005214 <create+0x70>
    80005236:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005238:	85da                	mv	a1,s6
    8000523a:	4088                	lw	a0,0(s1)
    8000523c:	ffffe097          	auipc	ra,0xffffe
    80005240:	3d6080e7          	jalr	982(ra) # 80003612 <ialloc>
    80005244:	8a2a                	mv	s4,a0
    80005246:	c531                	beqz	a0,80005292 <create+0xee>
  ilock(ip);
    80005248:	ffffe097          	auipc	ra,0xffffe
    8000524c:	56e080e7          	jalr	1390(ra) # 800037b6 <ilock>
  ip->major = major;
    80005250:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005254:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005258:	4905                	li	s2,1
    8000525a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000525e:	8552                	mv	a0,s4
    80005260:	ffffe097          	auipc	ra,0xffffe
    80005264:	48a080e7          	jalr	1162(ra) # 800036ea <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005268:	032b0d63          	beq	s6,s2,800052a2 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000526c:	004a2603          	lw	a2,4(s4)
    80005270:	fb040593          	addi	a1,s0,-80
    80005274:	8526                	mv	a0,s1
    80005276:	fffff097          	auipc	ra,0xfffff
    8000527a:	c5c080e7          	jalr	-932(ra) # 80003ed2 <dirlink>
    8000527e:	08054163          	bltz	a0,80005300 <create+0x15c>
  iunlockput(dp);
    80005282:	8526                	mv	a0,s1
    80005284:	ffffe097          	auipc	ra,0xffffe
    80005288:	798080e7          	jalr	1944(ra) # 80003a1c <iunlockput>
  return ip;
    8000528c:	8ad2                	mv	s5,s4
    8000528e:	7a02                	ld	s4,32(sp)
    80005290:	b751                	j	80005214 <create+0x70>
    iunlockput(dp);
    80005292:	8526                	mv	a0,s1
    80005294:	ffffe097          	auipc	ra,0xffffe
    80005298:	788080e7          	jalr	1928(ra) # 80003a1c <iunlockput>
    return 0;
    8000529c:	8ad2                	mv	s5,s4
    8000529e:	7a02                	ld	s4,32(sp)
    800052a0:	bf95                	j	80005214 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052a2:	004a2603          	lw	a2,4(s4)
    800052a6:	00003597          	auipc	a1,0x3
    800052aa:	33258593          	addi	a1,a1,818 # 800085d8 <etext+0x5d8>
    800052ae:	8552                	mv	a0,s4
    800052b0:	fffff097          	auipc	ra,0xfffff
    800052b4:	c22080e7          	jalr	-990(ra) # 80003ed2 <dirlink>
    800052b8:	04054463          	bltz	a0,80005300 <create+0x15c>
    800052bc:	40d0                	lw	a2,4(s1)
    800052be:	00003597          	auipc	a1,0x3
    800052c2:	32258593          	addi	a1,a1,802 # 800085e0 <etext+0x5e0>
    800052c6:	8552                	mv	a0,s4
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	c0a080e7          	jalr	-1014(ra) # 80003ed2 <dirlink>
    800052d0:	02054863          	bltz	a0,80005300 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    800052d4:	004a2603          	lw	a2,4(s4)
    800052d8:	fb040593          	addi	a1,s0,-80
    800052dc:	8526                	mv	a0,s1
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	bf4080e7          	jalr	-1036(ra) # 80003ed2 <dirlink>
    800052e6:	00054d63          	bltz	a0,80005300 <create+0x15c>
    dp->nlink++;  // for ".."
    800052ea:	04a4d783          	lhu	a5,74(s1)
    800052ee:	2785                	addiw	a5,a5,1
    800052f0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052f4:	8526                	mv	a0,s1
    800052f6:	ffffe097          	auipc	ra,0xffffe
    800052fa:	3f4080e7          	jalr	1012(ra) # 800036ea <iupdate>
    800052fe:	b751                	j	80005282 <create+0xde>
  ip->nlink = 0;
    80005300:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005304:	8552                	mv	a0,s4
    80005306:	ffffe097          	auipc	ra,0xffffe
    8000530a:	3e4080e7          	jalr	996(ra) # 800036ea <iupdate>
  iunlockput(ip);
    8000530e:	8552                	mv	a0,s4
    80005310:	ffffe097          	auipc	ra,0xffffe
    80005314:	70c080e7          	jalr	1804(ra) # 80003a1c <iunlockput>
  iunlockput(dp);
    80005318:	8526                	mv	a0,s1
    8000531a:	ffffe097          	auipc	ra,0xffffe
    8000531e:	702080e7          	jalr	1794(ra) # 80003a1c <iunlockput>
  return 0;
    80005322:	7a02                	ld	s4,32(sp)
    80005324:	bdc5                	j	80005214 <create+0x70>
    return 0;
    80005326:	8aaa                	mv	s5,a0
    80005328:	b5f5                	j	80005214 <create+0x70>

000000008000532a <sys_dup>:
{
    8000532a:	7179                	addi	sp,sp,-48
    8000532c:	f406                	sd	ra,40(sp)
    8000532e:	f022                	sd	s0,32(sp)
    80005330:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005332:	fd840613          	addi	a2,s0,-40
    80005336:	4581                	li	a1,0
    80005338:	4501                	li	a0,0
    8000533a:	00000097          	auipc	ra,0x0
    8000533e:	dc8080e7          	jalr	-568(ra) # 80005102 <argfd>
    return -1;
    80005342:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005344:	02054763          	bltz	a0,80005372 <sys_dup+0x48>
    80005348:	ec26                	sd	s1,24(sp)
    8000534a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000534c:	fd843903          	ld	s2,-40(s0)
    80005350:	854a                	mv	a0,s2
    80005352:	00000097          	auipc	ra,0x0
    80005356:	e10080e7          	jalr	-496(ra) # 80005162 <fdalloc>
    8000535a:	84aa                	mv	s1,a0
    return -1;
    8000535c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000535e:	00054f63          	bltz	a0,8000537c <sys_dup+0x52>
  filedup(f);
    80005362:	854a                	mv	a0,s2
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	298080e7          	jalr	664(ra) # 800045fc <filedup>
  return fd;
    8000536c:	87a6                	mv	a5,s1
    8000536e:	64e2                	ld	s1,24(sp)
    80005370:	6942                	ld	s2,16(sp)
}
    80005372:	853e                	mv	a0,a5
    80005374:	70a2                	ld	ra,40(sp)
    80005376:	7402                	ld	s0,32(sp)
    80005378:	6145                	addi	sp,sp,48
    8000537a:	8082                	ret
    8000537c:	64e2                	ld	s1,24(sp)
    8000537e:	6942                	ld	s2,16(sp)
    80005380:	bfcd                	j	80005372 <sys_dup+0x48>

0000000080005382 <sys_read>:
{
    80005382:	7179                	addi	sp,sp,-48
    80005384:	f406                	sd	ra,40(sp)
    80005386:	f022                	sd	s0,32(sp)
    80005388:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000538a:	fd840593          	addi	a1,s0,-40
    8000538e:	4505                	li	a0,1
    80005390:	ffffe097          	auipc	ra,0xffffe
    80005394:	802080e7          	jalr	-2046(ra) # 80002b92 <argaddr>
  argint(2, &n);
    80005398:	fe440593          	addi	a1,s0,-28
    8000539c:	4509                	li	a0,2
    8000539e:	ffffd097          	auipc	ra,0xffffd
    800053a2:	7d4080e7          	jalr	2004(ra) # 80002b72 <argint>
  if(argfd(0, 0, &f) < 0)
    800053a6:	fe840613          	addi	a2,s0,-24
    800053aa:	4581                	li	a1,0
    800053ac:	4501                	li	a0,0
    800053ae:	00000097          	auipc	ra,0x0
    800053b2:	d54080e7          	jalr	-684(ra) # 80005102 <argfd>
    800053b6:	87aa                	mv	a5,a0
    return -1;
    800053b8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053ba:	0007cc63          	bltz	a5,800053d2 <sys_read+0x50>
  return fileread(f, p, n);
    800053be:	fe442603          	lw	a2,-28(s0)
    800053c2:	fd843583          	ld	a1,-40(s0)
    800053c6:	fe843503          	ld	a0,-24(s0)
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	3d8080e7          	jalr	984(ra) # 800047a2 <fileread>
}
    800053d2:	70a2                	ld	ra,40(sp)
    800053d4:	7402                	ld	s0,32(sp)
    800053d6:	6145                	addi	sp,sp,48
    800053d8:	8082                	ret

00000000800053da <sys_write>:
{
    800053da:	7179                	addi	sp,sp,-48
    800053dc:	f406                	sd	ra,40(sp)
    800053de:	f022                	sd	s0,32(sp)
    800053e0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053e2:	fd840593          	addi	a1,s0,-40
    800053e6:	4505                	li	a0,1
    800053e8:	ffffd097          	auipc	ra,0xffffd
    800053ec:	7aa080e7          	jalr	1962(ra) # 80002b92 <argaddr>
  argint(2, &n);
    800053f0:	fe440593          	addi	a1,s0,-28
    800053f4:	4509                	li	a0,2
    800053f6:	ffffd097          	auipc	ra,0xffffd
    800053fa:	77c080e7          	jalr	1916(ra) # 80002b72 <argint>
  if(argfd(0, 0, &f) < 0)
    800053fe:	fe840613          	addi	a2,s0,-24
    80005402:	4581                	li	a1,0
    80005404:	4501                	li	a0,0
    80005406:	00000097          	auipc	ra,0x0
    8000540a:	cfc080e7          	jalr	-772(ra) # 80005102 <argfd>
    8000540e:	87aa                	mv	a5,a0
    return -1;
    80005410:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005412:	0007cc63          	bltz	a5,8000542a <sys_write+0x50>
  return filewrite(f, p, n);
    80005416:	fe442603          	lw	a2,-28(s0)
    8000541a:	fd843583          	ld	a1,-40(s0)
    8000541e:	fe843503          	ld	a0,-24(s0)
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	452080e7          	jalr	1106(ra) # 80004874 <filewrite>
}
    8000542a:	70a2                	ld	ra,40(sp)
    8000542c:	7402                	ld	s0,32(sp)
    8000542e:	6145                	addi	sp,sp,48
    80005430:	8082                	ret

0000000080005432 <sys_close>:
{
    80005432:	1101                	addi	sp,sp,-32
    80005434:	ec06                	sd	ra,24(sp)
    80005436:	e822                	sd	s0,16(sp)
    80005438:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000543a:	fe040613          	addi	a2,s0,-32
    8000543e:	fec40593          	addi	a1,s0,-20
    80005442:	4501                	li	a0,0
    80005444:	00000097          	auipc	ra,0x0
    80005448:	cbe080e7          	jalr	-834(ra) # 80005102 <argfd>
    return -1;
    8000544c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000544e:	02054463          	bltz	a0,80005476 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005452:	ffffc097          	auipc	ra,0xffffc
    80005456:	600080e7          	jalr	1536(ra) # 80001a52 <myproc>
    8000545a:	fec42783          	lw	a5,-20(s0)
    8000545e:	07e9                	addi	a5,a5,26
    80005460:	078e                	slli	a5,a5,0x3
    80005462:	953e                	add	a0,a0,a5
    80005464:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005468:	fe043503          	ld	a0,-32(s0)
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	1e2080e7          	jalr	482(ra) # 8000464e <fileclose>
  return 0;
    80005474:	4781                	li	a5,0
}
    80005476:	853e                	mv	a0,a5
    80005478:	60e2                	ld	ra,24(sp)
    8000547a:	6442                	ld	s0,16(sp)
    8000547c:	6105                	addi	sp,sp,32
    8000547e:	8082                	ret

0000000080005480 <sys_fstat>:
{
    80005480:	1101                	addi	sp,sp,-32
    80005482:	ec06                	sd	ra,24(sp)
    80005484:	e822                	sd	s0,16(sp)
    80005486:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005488:	fe040593          	addi	a1,s0,-32
    8000548c:	4505                	li	a0,1
    8000548e:	ffffd097          	auipc	ra,0xffffd
    80005492:	704080e7          	jalr	1796(ra) # 80002b92 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005496:	fe840613          	addi	a2,s0,-24
    8000549a:	4581                	li	a1,0
    8000549c:	4501                	li	a0,0
    8000549e:	00000097          	auipc	ra,0x0
    800054a2:	c64080e7          	jalr	-924(ra) # 80005102 <argfd>
    800054a6:	87aa                	mv	a5,a0
    return -1;
    800054a8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054aa:	0007ca63          	bltz	a5,800054be <sys_fstat+0x3e>
  return filestat(f, st);
    800054ae:	fe043583          	ld	a1,-32(s0)
    800054b2:	fe843503          	ld	a0,-24(s0)
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	27a080e7          	jalr	634(ra) # 80004730 <filestat>
}
    800054be:	60e2                	ld	ra,24(sp)
    800054c0:	6442                	ld	s0,16(sp)
    800054c2:	6105                	addi	sp,sp,32
    800054c4:	8082                	ret

00000000800054c6 <sys_link>:
{
    800054c6:	7169                	addi	sp,sp,-304
    800054c8:	f606                	sd	ra,296(sp)
    800054ca:	f222                	sd	s0,288(sp)
    800054cc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054ce:	08000613          	li	a2,128
    800054d2:	ed040593          	addi	a1,s0,-304
    800054d6:	4501                	li	a0,0
    800054d8:	ffffd097          	auipc	ra,0xffffd
    800054dc:	6da080e7          	jalr	1754(ra) # 80002bb2 <argstr>
    return -1;
    800054e0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054e2:	12054663          	bltz	a0,8000560e <sys_link+0x148>
    800054e6:	08000613          	li	a2,128
    800054ea:	f5040593          	addi	a1,s0,-176
    800054ee:	4505                	li	a0,1
    800054f0:	ffffd097          	auipc	ra,0xffffd
    800054f4:	6c2080e7          	jalr	1730(ra) # 80002bb2 <argstr>
    return -1;
    800054f8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054fa:	10054a63          	bltz	a0,8000560e <sys_link+0x148>
    800054fe:	ee26                	sd	s1,280(sp)
  begin_op();
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	c84080e7          	jalr	-892(ra) # 80004184 <begin_op>
  if((ip = namei(old)) == 0){
    80005508:	ed040513          	addi	a0,s0,-304
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	a78080e7          	jalr	-1416(ra) # 80003f84 <namei>
    80005514:	84aa                	mv	s1,a0
    80005516:	c949                	beqz	a0,800055a8 <sys_link+0xe2>
  ilock(ip);
    80005518:	ffffe097          	auipc	ra,0xffffe
    8000551c:	29e080e7          	jalr	670(ra) # 800037b6 <ilock>
  if(ip->type == T_DIR){
    80005520:	04449703          	lh	a4,68(s1)
    80005524:	4785                	li	a5,1
    80005526:	08f70863          	beq	a4,a5,800055b6 <sys_link+0xf0>
    8000552a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000552c:	04a4d783          	lhu	a5,74(s1)
    80005530:	2785                	addiw	a5,a5,1
    80005532:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005536:	8526                	mv	a0,s1
    80005538:	ffffe097          	auipc	ra,0xffffe
    8000553c:	1b2080e7          	jalr	434(ra) # 800036ea <iupdate>
  iunlock(ip);
    80005540:	8526                	mv	a0,s1
    80005542:	ffffe097          	auipc	ra,0xffffe
    80005546:	33a080e7          	jalr	826(ra) # 8000387c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000554a:	fd040593          	addi	a1,s0,-48
    8000554e:	f5040513          	addi	a0,s0,-176
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	a50080e7          	jalr	-1456(ra) # 80003fa2 <nameiparent>
    8000555a:	892a                	mv	s2,a0
    8000555c:	cd35                	beqz	a0,800055d8 <sys_link+0x112>
  ilock(dp);
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	258080e7          	jalr	600(ra) # 800037b6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005566:	00092703          	lw	a4,0(s2)
    8000556a:	409c                	lw	a5,0(s1)
    8000556c:	06f71163          	bne	a4,a5,800055ce <sys_link+0x108>
    80005570:	40d0                	lw	a2,4(s1)
    80005572:	fd040593          	addi	a1,s0,-48
    80005576:	854a                	mv	a0,s2
    80005578:	fffff097          	auipc	ra,0xfffff
    8000557c:	95a080e7          	jalr	-1702(ra) # 80003ed2 <dirlink>
    80005580:	04054763          	bltz	a0,800055ce <sys_link+0x108>
  iunlockput(dp);
    80005584:	854a                	mv	a0,s2
    80005586:	ffffe097          	auipc	ra,0xffffe
    8000558a:	496080e7          	jalr	1174(ra) # 80003a1c <iunlockput>
  iput(ip);
    8000558e:	8526                	mv	a0,s1
    80005590:	ffffe097          	auipc	ra,0xffffe
    80005594:	3e4080e7          	jalr	996(ra) # 80003974 <iput>
  end_op();
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	c66080e7          	jalr	-922(ra) # 800041fe <end_op>
  return 0;
    800055a0:	4781                	li	a5,0
    800055a2:	64f2                	ld	s1,280(sp)
    800055a4:	6952                	ld	s2,272(sp)
    800055a6:	a0a5                	j	8000560e <sys_link+0x148>
    end_op();
    800055a8:	fffff097          	auipc	ra,0xfffff
    800055ac:	c56080e7          	jalr	-938(ra) # 800041fe <end_op>
    return -1;
    800055b0:	57fd                	li	a5,-1
    800055b2:	64f2                	ld	s1,280(sp)
    800055b4:	a8a9                	j	8000560e <sys_link+0x148>
    iunlockput(ip);
    800055b6:	8526                	mv	a0,s1
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	464080e7          	jalr	1124(ra) # 80003a1c <iunlockput>
    end_op();
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	c3e080e7          	jalr	-962(ra) # 800041fe <end_op>
    return -1;
    800055c8:	57fd                	li	a5,-1
    800055ca:	64f2                	ld	s1,280(sp)
    800055cc:	a089                	j	8000560e <sys_link+0x148>
    iunlockput(dp);
    800055ce:	854a                	mv	a0,s2
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	44c080e7          	jalr	1100(ra) # 80003a1c <iunlockput>
  ilock(ip);
    800055d8:	8526                	mv	a0,s1
    800055da:	ffffe097          	auipc	ra,0xffffe
    800055de:	1dc080e7          	jalr	476(ra) # 800037b6 <ilock>
  ip->nlink--;
    800055e2:	04a4d783          	lhu	a5,74(s1)
    800055e6:	37fd                	addiw	a5,a5,-1
    800055e8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055ec:	8526                	mv	a0,s1
    800055ee:	ffffe097          	auipc	ra,0xffffe
    800055f2:	0fc080e7          	jalr	252(ra) # 800036ea <iupdate>
  iunlockput(ip);
    800055f6:	8526                	mv	a0,s1
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	424080e7          	jalr	1060(ra) # 80003a1c <iunlockput>
  end_op();
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	bfe080e7          	jalr	-1026(ra) # 800041fe <end_op>
  return -1;
    80005608:	57fd                	li	a5,-1
    8000560a:	64f2                	ld	s1,280(sp)
    8000560c:	6952                	ld	s2,272(sp)
}
    8000560e:	853e                	mv	a0,a5
    80005610:	70b2                	ld	ra,296(sp)
    80005612:	7412                	ld	s0,288(sp)
    80005614:	6155                	addi	sp,sp,304
    80005616:	8082                	ret

0000000080005618 <sys_unlink>:
{
    80005618:	7151                	addi	sp,sp,-240
    8000561a:	f586                	sd	ra,232(sp)
    8000561c:	f1a2                	sd	s0,224(sp)
    8000561e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005620:	08000613          	li	a2,128
    80005624:	f3040593          	addi	a1,s0,-208
    80005628:	4501                	li	a0,0
    8000562a:	ffffd097          	auipc	ra,0xffffd
    8000562e:	588080e7          	jalr	1416(ra) # 80002bb2 <argstr>
    80005632:	1a054a63          	bltz	a0,800057e6 <sys_unlink+0x1ce>
    80005636:	eda6                	sd	s1,216(sp)
  begin_op();
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	b4c080e7          	jalr	-1204(ra) # 80004184 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005640:	fb040593          	addi	a1,s0,-80
    80005644:	f3040513          	addi	a0,s0,-208
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	95a080e7          	jalr	-1702(ra) # 80003fa2 <nameiparent>
    80005650:	84aa                	mv	s1,a0
    80005652:	cd71                	beqz	a0,8000572e <sys_unlink+0x116>
  ilock(dp);
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	162080e7          	jalr	354(ra) # 800037b6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000565c:	00003597          	auipc	a1,0x3
    80005660:	f7c58593          	addi	a1,a1,-132 # 800085d8 <etext+0x5d8>
    80005664:	fb040513          	addi	a0,s0,-80
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	640080e7          	jalr	1600(ra) # 80003ca8 <namecmp>
    80005670:	14050c63          	beqz	a0,800057c8 <sys_unlink+0x1b0>
    80005674:	00003597          	auipc	a1,0x3
    80005678:	f6c58593          	addi	a1,a1,-148 # 800085e0 <etext+0x5e0>
    8000567c:	fb040513          	addi	a0,s0,-80
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	628080e7          	jalr	1576(ra) # 80003ca8 <namecmp>
    80005688:	14050063          	beqz	a0,800057c8 <sys_unlink+0x1b0>
    8000568c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000568e:	f2c40613          	addi	a2,s0,-212
    80005692:	fb040593          	addi	a1,s0,-80
    80005696:	8526                	mv	a0,s1
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	62a080e7          	jalr	1578(ra) # 80003cc2 <dirlookup>
    800056a0:	892a                	mv	s2,a0
    800056a2:	12050263          	beqz	a0,800057c6 <sys_unlink+0x1ae>
  ilock(ip);
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	110080e7          	jalr	272(ra) # 800037b6 <ilock>
  if(ip->nlink < 1)
    800056ae:	04a91783          	lh	a5,74(s2)
    800056b2:	08f05563          	blez	a5,8000573c <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056b6:	04491703          	lh	a4,68(s2)
    800056ba:	4785                	li	a5,1
    800056bc:	08f70963          	beq	a4,a5,8000574e <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800056c0:	4641                	li	a2,16
    800056c2:	4581                	li	a1,0
    800056c4:	fc040513          	addi	a0,s0,-64
    800056c8:	ffffb097          	auipc	ra,0xffffb
    800056cc:	66c080e7          	jalr	1644(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056d0:	4741                	li	a4,16
    800056d2:	f2c42683          	lw	a3,-212(s0)
    800056d6:	fc040613          	addi	a2,s0,-64
    800056da:	4581                	li	a1,0
    800056dc:	8526                	mv	a0,s1
    800056de:	ffffe097          	auipc	ra,0xffffe
    800056e2:	4a0080e7          	jalr	1184(ra) # 80003b7e <writei>
    800056e6:	47c1                	li	a5,16
    800056e8:	0af51b63          	bne	a0,a5,8000579e <sys_unlink+0x186>
  if(ip->type == T_DIR){
    800056ec:	04491703          	lh	a4,68(s2)
    800056f0:	4785                	li	a5,1
    800056f2:	0af70f63          	beq	a4,a5,800057b0 <sys_unlink+0x198>
  iunlockput(dp);
    800056f6:	8526                	mv	a0,s1
    800056f8:	ffffe097          	auipc	ra,0xffffe
    800056fc:	324080e7          	jalr	804(ra) # 80003a1c <iunlockput>
  ip->nlink--;
    80005700:	04a95783          	lhu	a5,74(s2)
    80005704:	37fd                	addiw	a5,a5,-1
    80005706:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000570a:	854a                	mv	a0,s2
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	fde080e7          	jalr	-34(ra) # 800036ea <iupdate>
  iunlockput(ip);
    80005714:	854a                	mv	a0,s2
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	306080e7          	jalr	774(ra) # 80003a1c <iunlockput>
  end_op();
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	ae0080e7          	jalr	-1312(ra) # 800041fe <end_op>
  return 0;
    80005726:	4501                	li	a0,0
    80005728:	64ee                	ld	s1,216(sp)
    8000572a:	694e                	ld	s2,208(sp)
    8000572c:	a84d                	j	800057de <sys_unlink+0x1c6>
    end_op();
    8000572e:	fffff097          	auipc	ra,0xfffff
    80005732:	ad0080e7          	jalr	-1328(ra) # 800041fe <end_op>
    return -1;
    80005736:	557d                	li	a0,-1
    80005738:	64ee                	ld	s1,216(sp)
    8000573a:	a055                	j	800057de <sys_unlink+0x1c6>
    8000573c:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000573e:	00003517          	auipc	a0,0x3
    80005742:	eaa50513          	addi	a0,a0,-342 # 800085e8 <etext+0x5e8>
    80005746:	ffffb097          	auipc	ra,0xffffb
    8000574a:	e1a080e7          	jalr	-486(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000574e:	04c92703          	lw	a4,76(s2)
    80005752:	02000793          	li	a5,32
    80005756:	f6e7f5e3          	bgeu	a5,a4,800056c0 <sys_unlink+0xa8>
    8000575a:	e5ce                	sd	s3,200(sp)
    8000575c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005760:	4741                	li	a4,16
    80005762:	86ce                	mv	a3,s3
    80005764:	f1840613          	addi	a2,s0,-232
    80005768:	4581                	li	a1,0
    8000576a:	854a                	mv	a0,s2
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	302080e7          	jalr	770(ra) # 80003a6e <readi>
    80005774:	47c1                	li	a5,16
    80005776:	00f51c63          	bne	a0,a5,8000578e <sys_unlink+0x176>
    if(de.inum != 0)
    8000577a:	f1845783          	lhu	a5,-232(s0)
    8000577e:	e7b5                	bnez	a5,800057ea <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005780:	29c1                	addiw	s3,s3,16
    80005782:	04c92783          	lw	a5,76(s2)
    80005786:	fcf9ede3          	bltu	s3,a5,80005760 <sys_unlink+0x148>
    8000578a:	69ae                	ld	s3,200(sp)
    8000578c:	bf15                	j	800056c0 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    8000578e:	00003517          	auipc	a0,0x3
    80005792:	e7250513          	addi	a0,a0,-398 # 80008600 <etext+0x600>
    80005796:	ffffb097          	auipc	ra,0xffffb
    8000579a:	dca080e7          	jalr	-566(ra) # 80000560 <panic>
    8000579e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800057a0:	00003517          	auipc	a0,0x3
    800057a4:	e7850513          	addi	a0,a0,-392 # 80008618 <etext+0x618>
    800057a8:	ffffb097          	auipc	ra,0xffffb
    800057ac:	db8080e7          	jalr	-584(ra) # 80000560 <panic>
    dp->nlink--;
    800057b0:	04a4d783          	lhu	a5,74(s1)
    800057b4:	37fd                	addiw	a5,a5,-1
    800057b6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057ba:	8526                	mv	a0,s1
    800057bc:	ffffe097          	auipc	ra,0xffffe
    800057c0:	f2e080e7          	jalr	-210(ra) # 800036ea <iupdate>
    800057c4:	bf0d                	j	800056f6 <sys_unlink+0xde>
    800057c6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800057c8:	8526                	mv	a0,s1
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	252080e7          	jalr	594(ra) # 80003a1c <iunlockput>
  end_op();
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	a2c080e7          	jalr	-1492(ra) # 800041fe <end_op>
  return -1;
    800057da:	557d                	li	a0,-1
    800057dc:	64ee                	ld	s1,216(sp)
}
    800057de:	70ae                	ld	ra,232(sp)
    800057e0:	740e                	ld	s0,224(sp)
    800057e2:	616d                	addi	sp,sp,240
    800057e4:	8082                	ret
    return -1;
    800057e6:	557d                	li	a0,-1
    800057e8:	bfdd                	j	800057de <sys_unlink+0x1c6>
    iunlockput(ip);
    800057ea:	854a                	mv	a0,s2
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	230080e7          	jalr	560(ra) # 80003a1c <iunlockput>
    goto bad;
    800057f4:	694e                	ld	s2,208(sp)
    800057f6:	69ae                	ld	s3,200(sp)
    800057f8:	bfc1                	j	800057c8 <sys_unlink+0x1b0>

00000000800057fa <sys_open>:

uint64
sys_open(void)
{
    800057fa:	7131                	addi	sp,sp,-192
    800057fc:	fd06                	sd	ra,184(sp)
    800057fe:	f922                	sd	s0,176(sp)
    80005800:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005802:	f4c40593          	addi	a1,s0,-180
    80005806:	4505                	li	a0,1
    80005808:	ffffd097          	auipc	ra,0xffffd
    8000580c:	36a080e7          	jalr	874(ra) # 80002b72 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005810:	08000613          	li	a2,128
    80005814:	f5040593          	addi	a1,s0,-176
    80005818:	4501                	li	a0,0
    8000581a:	ffffd097          	auipc	ra,0xffffd
    8000581e:	398080e7          	jalr	920(ra) # 80002bb2 <argstr>
    80005822:	87aa                	mv	a5,a0
    return -1;
    80005824:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005826:	0a07ce63          	bltz	a5,800058e2 <sys_open+0xe8>
    8000582a:	f526                	sd	s1,168(sp)

  begin_op();
    8000582c:	fffff097          	auipc	ra,0xfffff
    80005830:	958080e7          	jalr	-1704(ra) # 80004184 <begin_op>

  if(omode & O_CREATE){
    80005834:	f4c42783          	lw	a5,-180(s0)
    80005838:	2007f793          	andi	a5,a5,512
    8000583c:	cfd5                	beqz	a5,800058f8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000583e:	4681                	li	a3,0
    80005840:	4601                	li	a2,0
    80005842:	4589                	li	a1,2
    80005844:	f5040513          	addi	a0,s0,-176
    80005848:	00000097          	auipc	ra,0x0
    8000584c:	95c080e7          	jalr	-1700(ra) # 800051a4 <create>
    80005850:	84aa                	mv	s1,a0
    if(ip == 0){
    80005852:	cd41                	beqz	a0,800058ea <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005854:	04449703          	lh	a4,68(s1)
    80005858:	478d                	li	a5,3
    8000585a:	00f71763          	bne	a4,a5,80005868 <sys_open+0x6e>
    8000585e:	0464d703          	lhu	a4,70(s1)
    80005862:	47a5                	li	a5,9
    80005864:	0ee7e163          	bltu	a5,a4,80005946 <sys_open+0x14c>
    80005868:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	d28080e7          	jalr	-728(ra) # 80004592 <filealloc>
    80005872:	892a                	mv	s2,a0
    80005874:	c97d                	beqz	a0,8000596a <sys_open+0x170>
    80005876:	ed4e                	sd	s3,152(sp)
    80005878:	00000097          	auipc	ra,0x0
    8000587c:	8ea080e7          	jalr	-1814(ra) # 80005162 <fdalloc>
    80005880:	89aa                	mv	s3,a0
    80005882:	0c054e63          	bltz	a0,8000595e <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005886:	04449703          	lh	a4,68(s1)
    8000588a:	478d                	li	a5,3
    8000588c:	0ef70c63          	beq	a4,a5,80005984 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005890:	4789                	li	a5,2
    80005892:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005896:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000589a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000589e:	f4c42783          	lw	a5,-180(s0)
    800058a2:	0017c713          	xori	a4,a5,1
    800058a6:	8b05                	andi	a4,a4,1
    800058a8:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058ac:	0037f713          	andi	a4,a5,3
    800058b0:	00e03733          	snez	a4,a4
    800058b4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058b8:	4007f793          	andi	a5,a5,1024
    800058bc:	c791                	beqz	a5,800058c8 <sys_open+0xce>
    800058be:	04449703          	lh	a4,68(s1)
    800058c2:	4789                	li	a5,2
    800058c4:	0cf70763          	beq	a4,a5,80005992 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    800058c8:	8526                	mv	a0,s1
    800058ca:	ffffe097          	auipc	ra,0xffffe
    800058ce:	fb2080e7          	jalr	-78(ra) # 8000387c <iunlock>
  end_op();
    800058d2:	fffff097          	auipc	ra,0xfffff
    800058d6:	92c080e7          	jalr	-1748(ra) # 800041fe <end_op>

  return fd;
    800058da:	854e                	mv	a0,s3
    800058dc:	74aa                	ld	s1,168(sp)
    800058de:	790a                	ld	s2,160(sp)
    800058e0:	69ea                	ld	s3,152(sp)
}
    800058e2:	70ea                	ld	ra,184(sp)
    800058e4:	744a                	ld	s0,176(sp)
    800058e6:	6129                	addi	sp,sp,192
    800058e8:	8082                	ret
      end_op();
    800058ea:	fffff097          	auipc	ra,0xfffff
    800058ee:	914080e7          	jalr	-1772(ra) # 800041fe <end_op>
      return -1;
    800058f2:	557d                	li	a0,-1
    800058f4:	74aa                	ld	s1,168(sp)
    800058f6:	b7f5                	j	800058e2 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    800058f8:	f5040513          	addi	a0,s0,-176
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	688080e7          	jalr	1672(ra) # 80003f84 <namei>
    80005904:	84aa                	mv	s1,a0
    80005906:	c90d                	beqz	a0,80005938 <sys_open+0x13e>
    ilock(ip);
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	eae080e7          	jalr	-338(ra) # 800037b6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005910:	04449703          	lh	a4,68(s1)
    80005914:	4785                	li	a5,1
    80005916:	f2f71fe3          	bne	a4,a5,80005854 <sys_open+0x5a>
    8000591a:	f4c42783          	lw	a5,-180(s0)
    8000591e:	d7a9                	beqz	a5,80005868 <sys_open+0x6e>
      iunlockput(ip);
    80005920:	8526                	mv	a0,s1
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	0fa080e7          	jalr	250(ra) # 80003a1c <iunlockput>
      end_op();
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	8d4080e7          	jalr	-1836(ra) # 800041fe <end_op>
      return -1;
    80005932:	557d                	li	a0,-1
    80005934:	74aa                	ld	s1,168(sp)
    80005936:	b775                	j	800058e2 <sys_open+0xe8>
      end_op();
    80005938:	fffff097          	auipc	ra,0xfffff
    8000593c:	8c6080e7          	jalr	-1850(ra) # 800041fe <end_op>
      return -1;
    80005940:	557d                	li	a0,-1
    80005942:	74aa                	ld	s1,168(sp)
    80005944:	bf79                	j	800058e2 <sys_open+0xe8>
    iunlockput(ip);
    80005946:	8526                	mv	a0,s1
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	0d4080e7          	jalr	212(ra) # 80003a1c <iunlockput>
    end_op();
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	8ae080e7          	jalr	-1874(ra) # 800041fe <end_op>
    return -1;
    80005958:	557d                	li	a0,-1
    8000595a:	74aa                	ld	s1,168(sp)
    8000595c:	b759                	j	800058e2 <sys_open+0xe8>
      fileclose(f);
    8000595e:	854a                	mv	a0,s2
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	cee080e7          	jalr	-786(ra) # 8000464e <fileclose>
    80005968:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000596a:	8526                	mv	a0,s1
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	0b0080e7          	jalr	176(ra) # 80003a1c <iunlockput>
    end_op();
    80005974:	fffff097          	auipc	ra,0xfffff
    80005978:	88a080e7          	jalr	-1910(ra) # 800041fe <end_op>
    return -1;
    8000597c:	557d                	li	a0,-1
    8000597e:	74aa                	ld	s1,168(sp)
    80005980:	790a                	ld	s2,160(sp)
    80005982:	b785                	j	800058e2 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005984:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005988:	04649783          	lh	a5,70(s1)
    8000598c:	02f91223          	sh	a5,36(s2)
    80005990:	b729                	j	8000589a <sys_open+0xa0>
    itrunc(ip);
    80005992:	8526                	mv	a0,s1
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	f34080e7          	jalr	-204(ra) # 800038c8 <itrunc>
    8000599c:	b735                	j	800058c8 <sys_open+0xce>

000000008000599e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000599e:	7175                	addi	sp,sp,-144
    800059a0:	e506                	sd	ra,136(sp)
    800059a2:	e122                	sd	s0,128(sp)
    800059a4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	7de080e7          	jalr	2014(ra) # 80004184 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059ae:	08000613          	li	a2,128
    800059b2:	f7040593          	addi	a1,s0,-144
    800059b6:	4501                	li	a0,0
    800059b8:	ffffd097          	auipc	ra,0xffffd
    800059bc:	1fa080e7          	jalr	506(ra) # 80002bb2 <argstr>
    800059c0:	02054963          	bltz	a0,800059f2 <sys_mkdir+0x54>
    800059c4:	4681                	li	a3,0
    800059c6:	4601                	li	a2,0
    800059c8:	4585                	li	a1,1
    800059ca:	f7040513          	addi	a0,s0,-144
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	7d6080e7          	jalr	2006(ra) # 800051a4 <create>
    800059d6:	cd11                	beqz	a0,800059f2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	044080e7          	jalr	68(ra) # 80003a1c <iunlockput>
  end_op();
    800059e0:	fffff097          	auipc	ra,0xfffff
    800059e4:	81e080e7          	jalr	-2018(ra) # 800041fe <end_op>
  return 0;
    800059e8:	4501                	li	a0,0
}
    800059ea:	60aa                	ld	ra,136(sp)
    800059ec:	640a                	ld	s0,128(sp)
    800059ee:	6149                	addi	sp,sp,144
    800059f0:	8082                	ret
    end_op();
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	80c080e7          	jalr	-2036(ra) # 800041fe <end_op>
    return -1;
    800059fa:	557d                	li	a0,-1
    800059fc:	b7fd                	j	800059ea <sys_mkdir+0x4c>

00000000800059fe <sys_mknod>:

uint64
sys_mknod(void)
{
    800059fe:	7135                	addi	sp,sp,-160
    80005a00:	ed06                	sd	ra,152(sp)
    80005a02:	e922                	sd	s0,144(sp)
    80005a04:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	77e080e7          	jalr	1918(ra) # 80004184 <begin_op>
  argint(1, &major);
    80005a0e:	f6c40593          	addi	a1,s0,-148
    80005a12:	4505                	li	a0,1
    80005a14:	ffffd097          	auipc	ra,0xffffd
    80005a18:	15e080e7          	jalr	350(ra) # 80002b72 <argint>
  argint(2, &minor);
    80005a1c:	f6840593          	addi	a1,s0,-152
    80005a20:	4509                	li	a0,2
    80005a22:	ffffd097          	auipc	ra,0xffffd
    80005a26:	150080e7          	jalr	336(ra) # 80002b72 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a2a:	08000613          	li	a2,128
    80005a2e:	f7040593          	addi	a1,s0,-144
    80005a32:	4501                	li	a0,0
    80005a34:	ffffd097          	auipc	ra,0xffffd
    80005a38:	17e080e7          	jalr	382(ra) # 80002bb2 <argstr>
    80005a3c:	02054b63          	bltz	a0,80005a72 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a40:	f6841683          	lh	a3,-152(s0)
    80005a44:	f6c41603          	lh	a2,-148(s0)
    80005a48:	458d                	li	a1,3
    80005a4a:	f7040513          	addi	a0,s0,-144
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	756080e7          	jalr	1878(ra) # 800051a4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a56:	cd11                	beqz	a0,80005a72 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	fc4080e7          	jalr	-60(ra) # 80003a1c <iunlockput>
  end_op();
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	79e080e7          	jalr	1950(ra) # 800041fe <end_op>
  return 0;
    80005a68:	4501                	li	a0,0
}
    80005a6a:	60ea                	ld	ra,152(sp)
    80005a6c:	644a                	ld	s0,144(sp)
    80005a6e:	610d                	addi	sp,sp,160
    80005a70:	8082                	ret
    end_op();
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	78c080e7          	jalr	1932(ra) # 800041fe <end_op>
    return -1;
    80005a7a:	557d                	li	a0,-1
    80005a7c:	b7fd                	j	80005a6a <sys_mknod+0x6c>

0000000080005a7e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a7e:	7135                	addi	sp,sp,-160
    80005a80:	ed06                	sd	ra,152(sp)
    80005a82:	e922                	sd	s0,144(sp)
    80005a84:	e14a                	sd	s2,128(sp)
    80005a86:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a88:	ffffc097          	auipc	ra,0xffffc
    80005a8c:	fca080e7          	jalr	-54(ra) # 80001a52 <myproc>
    80005a90:	892a                	mv	s2,a0
  
  begin_op();
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	6f2080e7          	jalr	1778(ra) # 80004184 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a9a:	08000613          	li	a2,128
    80005a9e:	f6040593          	addi	a1,s0,-160
    80005aa2:	4501                	li	a0,0
    80005aa4:	ffffd097          	auipc	ra,0xffffd
    80005aa8:	10e080e7          	jalr	270(ra) # 80002bb2 <argstr>
    80005aac:	04054d63          	bltz	a0,80005b06 <sys_chdir+0x88>
    80005ab0:	e526                	sd	s1,136(sp)
    80005ab2:	f6040513          	addi	a0,s0,-160
    80005ab6:	ffffe097          	auipc	ra,0xffffe
    80005aba:	4ce080e7          	jalr	1230(ra) # 80003f84 <namei>
    80005abe:	84aa                	mv	s1,a0
    80005ac0:	c131                	beqz	a0,80005b04 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	cf4080e7          	jalr	-780(ra) # 800037b6 <ilock>
  if(ip->type != T_DIR){
    80005aca:	04449703          	lh	a4,68(s1)
    80005ace:	4785                	li	a5,1
    80005ad0:	04f71163          	bne	a4,a5,80005b12 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ad4:	8526                	mv	a0,s1
    80005ad6:	ffffe097          	auipc	ra,0xffffe
    80005ada:	da6080e7          	jalr	-602(ra) # 8000387c <iunlock>
  iput(p->cwd);
    80005ade:	15093503          	ld	a0,336(s2)
    80005ae2:	ffffe097          	auipc	ra,0xffffe
    80005ae6:	e92080e7          	jalr	-366(ra) # 80003974 <iput>
  end_op();
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	714080e7          	jalr	1812(ra) # 800041fe <end_op>
  p->cwd = ip;
    80005af2:	14993823          	sd	s1,336(s2)
  return 0;
    80005af6:	4501                	li	a0,0
    80005af8:	64aa                	ld	s1,136(sp)
}
    80005afa:	60ea                	ld	ra,152(sp)
    80005afc:	644a                	ld	s0,144(sp)
    80005afe:	690a                	ld	s2,128(sp)
    80005b00:	610d                	addi	sp,sp,160
    80005b02:	8082                	ret
    80005b04:	64aa                	ld	s1,136(sp)
    end_op();
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	6f8080e7          	jalr	1784(ra) # 800041fe <end_op>
    return -1;
    80005b0e:	557d                	li	a0,-1
    80005b10:	b7ed                	j	80005afa <sys_chdir+0x7c>
    iunlockput(ip);
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	f08080e7          	jalr	-248(ra) # 80003a1c <iunlockput>
    end_op();
    80005b1c:	ffffe097          	auipc	ra,0xffffe
    80005b20:	6e2080e7          	jalr	1762(ra) # 800041fe <end_op>
    return -1;
    80005b24:	557d                	li	a0,-1
    80005b26:	64aa                	ld	s1,136(sp)
    80005b28:	bfc9                	j	80005afa <sys_chdir+0x7c>

0000000080005b2a <sys_exec>:

uint64
sys_exec(void)
{
    80005b2a:	7121                	addi	sp,sp,-448
    80005b2c:	ff06                	sd	ra,440(sp)
    80005b2e:	fb22                	sd	s0,432(sp)
    80005b30:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b32:	e4840593          	addi	a1,s0,-440
    80005b36:	4505                	li	a0,1
    80005b38:	ffffd097          	auipc	ra,0xffffd
    80005b3c:	05a080e7          	jalr	90(ra) # 80002b92 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b40:	08000613          	li	a2,128
    80005b44:	f5040593          	addi	a1,s0,-176
    80005b48:	4501                	li	a0,0
    80005b4a:	ffffd097          	auipc	ra,0xffffd
    80005b4e:	068080e7          	jalr	104(ra) # 80002bb2 <argstr>
    80005b52:	87aa                	mv	a5,a0
    return -1;
    80005b54:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b56:	0e07c263          	bltz	a5,80005c3a <sys_exec+0x110>
    80005b5a:	f726                	sd	s1,424(sp)
    80005b5c:	f34a                	sd	s2,416(sp)
    80005b5e:	ef4e                	sd	s3,408(sp)
    80005b60:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005b62:	10000613          	li	a2,256
    80005b66:	4581                	li	a1,0
    80005b68:	e5040513          	addi	a0,s0,-432
    80005b6c:	ffffb097          	auipc	ra,0xffffb
    80005b70:	1c8080e7          	jalr	456(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b74:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005b78:	89a6                	mv	s3,s1
    80005b7a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b7c:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b80:	00391513          	slli	a0,s2,0x3
    80005b84:	e4040593          	addi	a1,s0,-448
    80005b88:	e4843783          	ld	a5,-440(s0)
    80005b8c:	953e                	add	a0,a0,a5
    80005b8e:	ffffd097          	auipc	ra,0xffffd
    80005b92:	f46080e7          	jalr	-186(ra) # 80002ad4 <fetchaddr>
    80005b96:	02054a63          	bltz	a0,80005bca <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005b9a:	e4043783          	ld	a5,-448(s0)
    80005b9e:	c7b9                	beqz	a5,80005bec <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ba0:	ffffb097          	auipc	ra,0xffffb
    80005ba4:	fa8080e7          	jalr	-88(ra) # 80000b48 <kalloc>
    80005ba8:	85aa                	mv	a1,a0
    80005baa:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005bae:	cd11                	beqz	a0,80005bca <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005bb0:	6605                	lui	a2,0x1
    80005bb2:	e4043503          	ld	a0,-448(s0)
    80005bb6:	ffffd097          	auipc	ra,0xffffd
    80005bba:	f70080e7          	jalr	-144(ra) # 80002b26 <fetchstr>
    80005bbe:	00054663          	bltz	a0,80005bca <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005bc2:	0905                	addi	s2,s2,1
    80005bc4:	09a1                	addi	s3,s3,8
    80005bc6:	fb491de3          	bne	s2,s4,80005b80 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bca:	f5040913          	addi	s2,s0,-176
    80005bce:	6088                	ld	a0,0(s1)
    80005bd0:	c125                	beqz	a0,80005c30 <sys_exec+0x106>
    kfree(argv[i]);
    80005bd2:	ffffb097          	auipc	ra,0xffffb
    80005bd6:	e78080e7          	jalr	-392(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bda:	04a1                	addi	s1,s1,8
    80005bdc:	ff2499e3          	bne	s1,s2,80005bce <sys_exec+0xa4>
  return -1;
    80005be0:	557d                	li	a0,-1
    80005be2:	74ba                	ld	s1,424(sp)
    80005be4:	791a                	ld	s2,416(sp)
    80005be6:	69fa                	ld	s3,408(sp)
    80005be8:	6a5a                	ld	s4,400(sp)
    80005bea:	a881                	j	80005c3a <sys_exec+0x110>
      argv[i] = 0;
    80005bec:	0009079b          	sext.w	a5,s2
    80005bf0:	078e                	slli	a5,a5,0x3
    80005bf2:	fd078793          	addi	a5,a5,-48
    80005bf6:	97a2                	add	a5,a5,s0
    80005bf8:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005bfc:	e5040593          	addi	a1,s0,-432
    80005c00:	f5040513          	addi	a0,s0,-176
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	120080e7          	jalr	288(ra) # 80004d24 <exec>
    80005c0c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c0e:	f5040993          	addi	s3,s0,-176
    80005c12:	6088                	ld	a0,0(s1)
    80005c14:	c901                	beqz	a0,80005c24 <sys_exec+0xfa>
    kfree(argv[i]);
    80005c16:	ffffb097          	auipc	ra,0xffffb
    80005c1a:	e34080e7          	jalr	-460(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c1e:	04a1                	addi	s1,s1,8
    80005c20:	ff3499e3          	bne	s1,s3,80005c12 <sys_exec+0xe8>
  return ret;
    80005c24:	854a                	mv	a0,s2
    80005c26:	74ba                	ld	s1,424(sp)
    80005c28:	791a                	ld	s2,416(sp)
    80005c2a:	69fa                	ld	s3,408(sp)
    80005c2c:	6a5a                	ld	s4,400(sp)
    80005c2e:	a031                	j	80005c3a <sys_exec+0x110>
  return -1;
    80005c30:	557d                	li	a0,-1
    80005c32:	74ba                	ld	s1,424(sp)
    80005c34:	791a                	ld	s2,416(sp)
    80005c36:	69fa                	ld	s3,408(sp)
    80005c38:	6a5a                	ld	s4,400(sp)
}
    80005c3a:	70fa                	ld	ra,440(sp)
    80005c3c:	745a                	ld	s0,432(sp)
    80005c3e:	6139                	addi	sp,sp,448
    80005c40:	8082                	ret

0000000080005c42 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c42:	7139                	addi	sp,sp,-64
    80005c44:	fc06                	sd	ra,56(sp)
    80005c46:	f822                	sd	s0,48(sp)
    80005c48:	f426                	sd	s1,40(sp)
    80005c4a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c4c:	ffffc097          	auipc	ra,0xffffc
    80005c50:	e06080e7          	jalr	-506(ra) # 80001a52 <myproc>
    80005c54:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c56:	fd840593          	addi	a1,s0,-40
    80005c5a:	4501                	li	a0,0
    80005c5c:	ffffd097          	auipc	ra,0xffffd
    80005c60:	f36080e7          	jalr	-202(ra) # 80002b92 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c64:	fc840593          	addi	a1,s0,-56
    80005c68:	fd040513          	addi	a0,s0,-48
    80005c6c:	fffff097          	auipc	ra,0xfffff
    80005c70:	d50080e7          	jalr	-688(ra) # 800049bc <pipealloc>
    return -1;
    80005c74:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c76:	0c054463          	bltz	a0,80005d3e <sys_pipe+0xfc>
  fd0 = -1;
    80005c7a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c7e:	fd043503          	ld	a0,-48(s0)
    80005c82:	fffff097          	auipc	ra,0xfffff
    80005c86:	4e0080e7          	jalr	1248(ra) # 80005162 <fdalloc>
    80005c8a:	fca42223          	sw	a0,-60(s0)
    80005c8e:	08054b63          	bltz	a0,80005d24 <sys_pipe+0xe2>
    80005c92:	fc843503          	ld	a0,-56(s0)
    80005c96:	fffff097          	auipc	ra,0xfffff
    80005c9a:	4cc080e7          	jalr	1228(ra) # 80005162 <fdalloc>
    80005c9e:	fca42023          	sw	a0,-64(s0)
    80005ca2:	06054863          	bltz	a0,80005d12 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ca6:	4691                	li	a3,4
    80005ca8:	fc440613          	addi	a2,s0,-60
    80005cac:	fd843583          	ld	a1,-40(s0)
    80005cb0:	68a8                	ld	a0,80(s1)
    80005cb2:	ffffc097          	auipc	ra,0xffffc
    80005cb6:	a38080e7          	jalr	-1480(ra) # 800016ea <copyout>
    80005cba:	02054063          	bltz	a0,80005cda <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cbe:	4691                	li	a3,4
    80005cc0:	fc040613          	addi	a2,s0,-64
    80005cc4:	fd843583          	ld	a1,-40(s0)
    80005cc8:	0591                	addi	a1,a1,4
    80005cca:	68a8                	ld	a0,80(s1)
    80005ccc:	ffffc097          	auipc	ra,0xffffc
    80005cd0:	a1e080e7          	jalr	-1506(ra) # 800016ea <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005cd4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cd6:	06055463          	bgez	a0,80005d3e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005cda:	fc442783          	lw	a5,-60(s0)
    80005cde:	07e9                	addi	a5,a5,26
    80005ce0:	078e                	slli	a5,a5,0x3
    80005ce2:	97a6                	add	a5,a5,s1
    80005ce4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ce8:	fc042783          	lw	a5,-64(s0)
    80005cec:	07e9                	addi	a5,a5,26
    80005cee:	078e                	slli	a5,a5,0x3
    80005cf0:	94be                	add	s1,s1,a5
    80005cf2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005cf6:	fd043503          	ld	a0,-48(s0)
    80005cfa:	fffff097          	auipc	ra,0xfffff
    80005cfe:	954080e7          	jalr	-1708(ra) # 8000464e <fileclose>
    fileclose(wf);
    80005d02:	fc843503          	ld	a0,-56(s0)
    80005d06:	fffff097          	auipc	ra,0xfffff
    80005d0a:	948080e7          	jalr	-1720(ra) # 8000464e <fileclose>
    return -1;
    80005d0e:	57fd                	li	a5,-1
    80005d10:	a03d                	j	80005d3e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005d12:	fc442783          	lw	a5,-60(s0)
    80005d16:	0007c763          	bltz	a5,80005d24 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005d1a:	07e9                	addi	a5,a5,26
    80005d1c:	078e                	slli	a5,a5,0x3
    80005d1e:	97a6                	add	a5,a5,s1
    80005d20:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005d24:	fd043503          	ld	a0,-48(s0)
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	926080e7          	jalr	-1754(ra) # 8000464e <fileclose>
    fileclose(wf);
    80005d30:	fc843503          	ld	a0,-56(s0)
    80005d34:	fffff097          	auipc	ra,0xfffff
    80005d38:	91a080e7          	jalr	-1766(ra) # 8000464e <fileclose>
    return -1;
    80005d3c:	57fd                	li	a5,-1
}
    80005d3e:	853e                	mv	a0,a5
    80005d40:	70e2                	ld	ra,56(sp)
    80005d42:	7442                	ld	s0,48(sp)
    80005d44:	74a2                	ld	s1,40(sp)
    80005d46:	6121                	addi	sp,sp,64
    80005d48:	8082                	ret
    80005d4a:	0000                	unimp
    80005d4c:	0000                	unimp
	...

0000000080005d50 <kernelvec>:
    80005d50:	7111                	addi	sp,sp,-256
    80005d52:	e006                	sd	ra,0(sp)
    80005d54:	e40a                	sd	sp,8(sp)
    80005d56:	e80e                	sd	gp,16(sp)
    80005d58:	ec12                	sd	tp,24(sp)
    80005d5a:	f016                	sd	t0,32(sp)
    80005d5c:	f41a                	sd	t1,40(sp)
    80005d5e:	f81e                	sd	t2,48(sp)
    80005d60:	fc22                	sd	s0,56(sp)
    80005d62:	e0a6                	sd	s1,64(sp)
    80005d64:	e4aa                	sd	a0,72(sp)
    80005d66:	e8ae                	sd	a1,80(sp)
    80005d68:	ecb2                	sd	a2,88(sp)
    80005d6a:	f0b6                	sd	a3,96(sp)
    80005d6c:	f4ba                	sd	a4,104(sp)
    80005d6e:	f8be                	sd	a5,112(sp)
    80005d70:	fcc2                	sd	a6,120(sp)
    80005d72:	e146                	sd	a7,128(sp)
    80005d74:	e54a                	sd	s2,136(sp)
    80005d76:	e94e                	sd	s3,144(sp)
    80005d78:	ed52                	sd	s4,152(sp)
    80005d7a:	f156                	sd	s5,160(sp)
    80005d7c:	f55a                	sd	s6,168(sp)
    80005d7e:	f95e                	sd	s7,176(sp)
    80005d80:	fd62                	sd	s8,184(sp)
    80005d82:	e1e6                	sd	s9,192(sp)
    80005d84:	e5ea                	sd	s10,200(sp)
    80005d86:	e9ee                	sd	s11,208(sp)
    80005d88:	edf2                	sd	t3,216(sp)
    80005d8a:	f1f6                	sd	t4,224(sp)
    80005d8c:	f5fa                	sd	t5,232(sp)
    80005d8e:	f9fe                	sd	t6,240(sp)
    80005d90:	c11fc0ef          	jal	800029a0 <kerneltrap>
    80005d94:	6082                	ld	ra,0(sp)
    80005d96:	6122                	ld	sp,8(sp)
    80005d98:	61c2                	ld	gp,16(sp)
    80005d9a:	7282                	ld	t0,32(sp)
    80005d9c:	7322                	ld	t1,40(sp)
    80005d9e:	73c2                	ld	t2,48(sp)
    80005da0:	7462                	ld	s0,56(sp)
    80005da2:	6486                	ld	s1,64(sp)
    80005da4:	6526                	ld	a0,72(sp)
    80005da6:	65c6                	ld	a1,80(sp)
    80005da8:	6666                	ld	a2,88(sp)
    80005daa:	7686                	ld	a3,96(sp)
    80005dac:	7726                	ld	a4,104(sp)
    80005dae:	77c6                	ld	a5,112(sp)
    80005db0:	7866                	ld	a6,120(sp)
    80005db2:	688a                	ld	a7,128(sp)
    80005db4:	692a                	ld	s2,136(sp)
    80005db6:	69ca                	ld	s3,144(sp)
    80005db8:	6a6a                	ld	s4,152(sp)
    80005dba:	7a8a                	ld	s5,160(sp)
    80005dbc:	7b2a                	ld	s6,168(sp)
    80005dbe:	7bca                	ld	s7,176(sp)
    80005dc0:	7c6a                	ld	s8,184(sp)
    80005dc2:	6c8e                	ld	s9,192(sp)
    80005dc4:	6d2e                	ld	s10,200(sp)
    80005dc6:	6dce                	ld	s11,208(sp)
    80005dc8:	6e6e                	ld	t3,216(sp)
    80005dca:	7e8e                	ld	t4,224(sp)
    80005dcc:	7f2e                	ld	t5,232(sp)
    80005dce:	7fce                	ld	t6,240(sp)
    80005dd0:	6111                	addi	sp,sp,256
    80005dd2:	10200073          	sret
    80005dd6:	00000013          	nop
    80005dda:	00000013          	nop
    80005dde:	0001                	nop

0000000080005de0 <timervec>:
    80005de0:	34051573          	csrrw	a0,mscratch,a0
    80005de4:	e10c                	sd	a1,0(a0)
    80005de6:	e510                	sd	a2,8(a0)
    80005de8:	e914                	sd	a3,16(a0)
    80005dea:	6d0c                	ld	a1,24(a0)
    80005dec:	7110                	ld	a2,32(a0)
    80005dee:	6194                	ld	a3,0(a1)
    80005df0:	96b2                	add	a3,a3,a2
    80005df2:	e194                	sd	a3,0(a1)
    80005df4:	4589                	li	a1,2
    80005df6:	14459073          	csrw	sip,a1
    80005dfa:	6914                	ld	a3,16(a0)
    80005dfc:	6510                	ld	a2,8(a0)
    80005dfe:	610c                	ld	a1,0(a0)
    80005e00:	34051573          	csrrw	a0,mscratch,a0
    80005e04:	30200073          	mret
	...

0000000080005e0a <sem_init>:
semaphore sem_table[MAX_SEM];

//sem_init for the array. It's executed in main.c on the kernel at start.
void
sem_init(void)
{
    80005e0a:	7179                	addi	sp,sp,-48
    80005e0c:	f406                	sd	ra,40(sp)
    80005e0e:	f022                	sd	s0,32(sp)
    80005e10:	ec26                	sd	s1,24(sp)
    80005e12:	e84a                	sd	s2,16(sp)
    80005e14:	e44e                	sd	s3,8(sp)
    80005e16:	e052                	sd	s4,0(sp)
    80005e18:	1800                	addi	s0,sp,48
    for (uint i = 0; i < MAX_SEM; i++) 
    80005e1a:	0001f497          	auipc	s1,0x1f
    80005e1e:	91e48493          	addi	s1,s1,-1762 # 80024738 <sem_table+0x8>
    80005e22:	00021a17          	auipc	s4,0x21
    80005e26:	916a0a13          	addi	s4,s4,-1770 # 80026738 <disk+0x8>
    {
        initlock(&sem_table[i].lock, "semaphore_lock");
    80005e2a:	00002997          	auipc	s3,0x2
    80005e2e:	7fe98993          	addi	s3,s3,2046 # 80008628 <etext+0x628>
        sem_table[i].value = -1;
    80005e32:	597d                	li	s2,-1
        initlock(&sem_table[i].lock, "semaphore_lock");
    80005e34:	85ce                	mv	a1,s3
    80005e36:	8526                	mv	a0,s1
    80005e38:	ffffb097          	auipc	ra,0xffffb
    80005e3c:	d70080e7          	jalr	-656(ra) # 80000ba8 <initlock>
        sem_table[i].value = -1;
    80005e40:	ff24ac23          	sw	s2,-8(s1)
    for (uint i = 0; i < MAX_SEM; i++) 
    80005e44:	02048493          	addi	s1,s1,32
    80005e48:	ff4496e3          	bne	s1,s4,80005e34 <sem_init+0x2a>
    }
}
    80005e4c:	70a2                	ld	ra,40(sp)
    80005e4e:	7402                	ld	s0,32(sp)
    80005e50:	64e2                	ld	s1,24(sp)
    80005e52:	6942                	ld	s2,16(sp)
    80005e54:	69a2                	ld	s3,8(sp)
    80005e56:	6a02                	ld	s4,0(sp)
    80005e58:	6145                	addi	sp,sp,48
    80005e5a:	8082                	ret

0000000080005e5c <sem_open>:

int
sem_open(int sem, int value)
{
    80005e5c:	7139                	addi	sp,sp,-64
    80005e5e:	fc06                	sd	ra,56(sp)
    80005e60:	f822                	sd	s0,48(sp)
    80005e62:	f04a                	sd	s2,32(sp)
    80005e64:	0080                	addi	s0,sp,64
    if (sem < 0 || sem >= MAX_SEM) return SEM_ERROR;
    80005e66:	0ff00793          	li	a5,255
    80005e6a:	4901                	li	s2,0
    80005e6c:	00a7f863          	bgeu	a5,a0,80005e7c <sem_open+0x20>
        ret = SEM_SUCCESS;
    }
    release(&sem_table[sem].lock);

    return ret;
}
    80005e70:	854a                	mv	a0,s2
    80005e72:	70e2                	ld	ra,56(sp)
    80005e74:	7442                	ld	s0,48(sp)
    80005e76:	7902                	ld	s2,32(sp)
    80005e78:	6121                	addi	sp,sp,64
    80005e7a:	8082                	ret
    80005e7c:	f426                	sd	s1,40(sp)
    80005e7e:	ec4e                	sd	s3,24(sp)
    80005e80:	e852                	sd	s4,16(sp)
    80005e82:	e456                	sd	s5,8(sp)
    80005e84:	89ae                	mv	s3,a1
    acquire(&sem_table[sem].lock);
    80005e86:	00551a93          	slli	s5,a0,0x5
    80005e8a:	008a8493          	addi	s1,s5,8
    80005e8e:	0001f917          	auipc	s2,0x1f
    80005e92:	8a290913          	addi	s2,s2,-1886 # 80024730 <sem_table>
    80005e96:	94ca                	add	s1,s1,s2
    80005e98:	8526                	mv	a0,s1
    80005e9a:	ffffb097          	auipc	ra,0xffffb
    80005e9e:	d9e080e7          	jalr	-610(ra) # 80000c38 <acquire>
    if (sem_table[sem].value == -1) //If not open yet, do it.
    80005ea2:	9956                	add	s2,s2,s5
    80005ea4:	00092703          	lw	a4,0(s2)
    80005ea8:	57fd                	li	a5,-1
    int ret = SEM_ERROR;
    80005eaa:	4901                	li	s2,0
    if (sem_table[sem].value == -1) //If not open yet, do it.
    80005eac:	00f70c63          	beq	a4,a5,80005ec4 <sem_open+0x68>
    release(&sem_table[sem].lock);
    80005eb0:	8526                	mv	a0,s1
    80005eb2:	ffffb097          	auipc	ra,0xffffb
    80005eb6:	e3a080e7          	jalr	-454(ra) # 80000cec <release>
    return ret;
    80005eba:	74a2                	ld	s1,40(sp)
    80005ebc:	69e2                	ld	s3,24(sp)
    80005ebe:	6a42                	ld	s4,16(sp)
    80005ec0:	6aa2                	ld	s5,8(sp)
    80005ec2:	b77d                	j	80005e70 <sem_open+0x14>
        sem_table[sem].value = value;
    80005ec4:	0001f797          	auipc	a5,0x1f
    80005ec8:	86c78793          	addi	a5,a5,-1940 # 80024730 <sem_table>
    80005ecc:	97d6                	add	a5,a5,s5
    80005ece:	0137a023          	sw	s3,0(a5)
        ret = SEM_SUCCESS;
    80005ed2:	4905                	li	s2,1
    80005ed4:	bff1                	j	80005eb0 <sem_open+0x54>

0000000080005ed6 <sem_close>:

int
sem_close(int sem)
{
   if (sem < 0 || sem >= MAX_SEM) return SEM_ERROR;
    80005ed6:	0ff00793          	li	a5,255
    80005eda:	00a7f463          	bgeu	a5,a0,80005ee2 <sem_close+0xc>
    80005ede:	4501                	li	a0,0
        sem_table[sem].value = -1;
    }
    release(&sem_table[sem].lock);

    return SEM_SUCCESS;
}
    80005ee0:	8082                	ret
{
    80005ee2:	7179                	addi	sp,sp,-48
    80005ee4:	f406                	sd	ra,40(sp)
    80005ee6:	f022                	sd	s0,32(sp)
    80005ee8:	ec26                	sd	s1,24(sp)
    80005eea:	e84a                	sd	s2,16(sp)
    80005eec:	e44e                	sd	s3,8(sp)
    80005eee:	e052                	sd	s4,0(sp)
    80005ef0:	1800                	addi	s0,sp,48
    acquire(&sem_table[sem].lock);
    80005ef2:	00551a13          	slli	s4,a0,0x5
    80005ef6:	008a0493          	addi	s1,s4,8
    80005efa:	0001f917          	auipc	s2,0x1f
    80005efe:	83690913          	addi	s2,s2,-1994 # 80024730 <sem_table>
    80005f02:	94ca                	add	s1,s1,s2
    80005f04:	8526                	mv	a0,s1
    80005f06:	ffffb097          	auipc	ra,0xffffb
    80005f0a:	d32080e7          	jalr	-718(ra) # 80000c38 <acquire>
    if (sem_table[sem].value > 0) 
    80005f0e:	9952                	add	s2,s2,s4
    80005f10:	00092783          	lw	a5,0(s2)
    80005f14:	00f05563          	blez	a5,80005f1e <sem_close+0x48>
        sem_table[sem].value = -1;
    80005f18:	577d                	li	a4,-1
    80005f1a:	00e92023          	sw	a4,0(s2)
    release(&sem_table[sem].lock);
    80005f1e:	8526                	mv	a0,s1
    80005f20:	ffffb097          	auipc	ra,0xffffb
    80005f24:	dcc080e7          	jalr	-564(ra) # 80000cec <release>
    return SEM_SUCCESS;
    80005f28:	4505                	li	a0,1
}
    80005f2a:	70a2                	ld	ra,40(sp)
    80005f2c:	7402                	ld	s0,32(sp)
    80005f2e:	64e2                	ld	s1,24(sp)
    80005f30:	6942                	ld	s2,16(sp)
    80005f32:	69a2                	ld	s3,8(sp)
    80005f34:	6a02                	ld	s4,0(sp)
    80005f36:	6145                	addi	sp,sp,48
    80005f38:	8082                	ret

0000000080005f3a <sem_up>:

int
sem_up(int sem)
{
    80005f3a:	7179                	addi	sp,sp,-48
    80005f3c:	f406                	sd	ra,40(sp)
    80005f3e:	f022                	sd	s0,32(sp)
    80005f40:	ec26                	sd	s1,24(sp)
    80005f42:	e84a                	sd	s2,16(sp)
    80005f44:	e44e                	sd	s3,8(sp)
    80005f46:	e052                	sd	s4,0(sp)
    80005f48:	1800                	addi	s0,sp,48
    80005f4a:	84aa                	mv	s1,a0
    acquire(&(sem_table[sem].lock));
    80005f4c:	00551a13          	slli	s4,a0,0x5
    80005f50:	008a0993          	addi	s3,s4,8
    80005f54:	0001e917          	auipc	s2,0x1e
    80005f58:	7dc90913          	addi	s2,s2,2012 # 80024730 <sem_table>
    80005f5c:	99ca                	add	s3,s3,s2
    80005f5e:	854e                	mv	a0,s3
    80005f60:	ffffb097          	auipc	ra,0xffffb
    80005f64:	cd8080e7          	jalr	-808(ra) # 80000c38 <acquire>

    if (sem_table[sem].value == -1 ) {
    80005f68:	9952                	add	s2,s2,s4
    80005f6a:	00092783          	lw	a5,0(s2)
    80005f6e:	577d                	li	a4,-1
    80005f70:	02e78a63          	beq	a5,a4,80005fa4 <sem_up+0x6a>
        printf("ERROR: Ilegal increase of closed semaphore.\n");
        release(&(sem_table[sem].lock));
        return SEM_ERROR;
    }

    if (sem_table[sem].value == 0)
    80005f74:	c7b9                	beqz	a5,80005fc2 <sem_up+0x88>
        wakeup(&(sem_table[sem]));

    (sem_table[sem].value) += 1;
    80005f76:	0496                	slli	s1,s1,0x5
    80005f78:	0001e797          	auipc	a5,0x1e
    80005f7c:	7b878793          	addi	a5,a5,1976 # 80024730 <sem_table>
    80005f80:	97a6                	add	a5,a5,s1
    80005f82:	4398                	lw	a4,0(a5)
    80005f84:	2705                	addiw	a4,a4,1
    80005f86:	c398                	sw	a4,0(a5)

    release(&(sem_table[sem].lock));
    80005f88:	854e                	mv	a0,s3
    80005f8a:	ffffb097          	auipc	ra,0xffffb
    80005f8e:	d62080e7          	jalr	-670(ra) # 80000cec <release>

    return SEM_SUCCESS;
    80005f92:	4505                	li	a0,1
}
    80005f94:	70a2                	ld	ra,40(sp)
    80005f96:	7402                	ld	s0,32(sp)
    80005f98:	64e2                	ld	s1,24(sp)
    80005f9a:	6942                	ld	s2,16(sp)
    80005f9c:	69a2                	ld	s3,8(sp)
    80005f9e:	6a02                	ld	s4,0(sp)
    80005fa0:	6145                	addi	sp,sp,48
    80005fa2:	8082                	ret
        printf("ERROR: Ilegal increase of closed semaphore.\n");
    80005fa4:	00002517          	auipc	a0,0x2
    80005fa8:	69450513          	addi	a0,a0,1684 # 80008638 <etext+0x638>
    80005fac:	ffffa097          	auipc	ra,0xffffa
    80005fb0:	5fe080e7          	jalr	1534(ra) # 800005aa <printf>
        release(&(sem_table[sem].lock));
    80005fb4:	854e                	mv	a0,s3
    80005fb6:	ffffb097          	auipc	ra,0xffffb
    80005fba:	d36080e7          	jalr	-714(ra) # 80000cec <release>
        return SEM_ERROR;
    80005fbe:	4501                	li	a0,0
    80005fc0:	bfd1                	j	80005f94 <sem_up+0x5a>
        wakeup(&(sem_table[sem]));
    80005fc2:	0001e517          	auipc	a0,0x1e
    80005fc6:	76e50513          	addi	a0,a0,1902 # 80024730 <sem_table>
    80005fca:	9552                	add	a0,a0,s4
    80005fcc:	ffffc097          	auipc	ra,0xffffc
    80005fd0:	194080e7          	jalr	404(ra) # 80002160 <wakeup>
    80005fd4:	b74d                	j	80005f76 <sem_up+0x3c>

0000000080005fd6 <sem_down>:

int
sem_down(int sem)
{
    80005fd6:	7179                	addi	sp,sp,-48
    80005fd8:	f406                	sd	ra,40(sp)
    80005fda:	f022                	sd	s0,32(sp)
    80005fdc:	ec26                	sd	s1,24(sp)
    80005fde:	e84a                	sd	s2,16(sp)
    80005fe0:	e44e                	sd	s3,8(sp)
    80005fe2:	e052                	sd	s4,0(sp)
    80005fe4:	1800                	addi	s0,sp,48
    80005fe6:	8a2a                	mv	s4,a0
 acquire(&(sem_table[sem].lock));
    80005fe8:	00551913          	slli	s2,a0,0x5
    80005fec:	00890493          	addi	s1,s2,8
    80005ff0:	0001e997          	auipc	s3,0x1e
    80005ff4:	74098993          	addi	s3,s3,1856 # 80024730 <sem_table>
    80005ff8:	94ce                	add	s1,s1,s3
    80005ffa:	8526                	mv	a0,s1
    80005ffc:	ffffb097          	auipc	ra,0xffffb
    80006000:	c3c080e7          	jalr	-964(ra) # 80000c38 <acquire>

    if (sem_table[sem].value == -1)
    80006004:	99ca                	add	s3,s3,s2
    80006006:	0009a783          	lw	a5,0(s3)
    8000600a:	577d                	li	a4,-1
    8000600c:	04e78363          	beq	a5,a4,80006052 <sem_down+0x7c>
        return SEM_ERROR;
    }

    while (sem_table[sem].value == 0)
    {
        sleep(&(sem_table[sem]), &(sem_table[sem].lock));
    80006010:	894e                	mv	s2,s3
    while (sem_table[sem].value == 0)
    80006012:	eb91                	bnez	a5,80006026 <sem_down+0x50>
        sleep(&(sem_table[sem]), &(sem_table[sem].lock));
    80006014:	85a6                	mv	a1,s1
    80006016:	854a                	mv	a0,s2
    80006018:	ffffc097          	auipc	ra,0xffffc
    8000601c:	0e4080e7          	jalr	228(ra) # 800020fc <sleep>
    while (sem_table[sem].value == 0)
    80006020:	0009a783          	lw	a5,0(s3)
    80006024:	dbe5                	beqz	a5,80006014 <sem_down+0x3e>
    }

    (sem_table[sem].value) -= 1;
    80006026:	0a16                	slli	s4,s4,0x5
    80006028:	0001e717          	auipc	a4,0x1e
    8000602c:	70870713          	addi	a4,a4,1800 # 80024730 <sem_table>
    80006030:	9752                	add	a4,a4,s4
    80006032:	37fd                	addiw	a5,a5,-1
    80006034:	c31c                	sw	a5,0(a4)

    release(&(sem_table[sem].lock));
    80006036:	8526                	mv	a0,s1
    80006038:	ffffb097          	auipc	ra,0xffffb
    8000603c:	cb4080e7          	jalr	-844(ra) # 80000cec <release>

    return SEM_SUCCESS;
    80006040:	4505                	li	a0,1
}
    80006042:	70a2                	ld	ra,40(sp)
    80006044:	7402                	ld	s0,32(sp)
    80006046:	64e2                	ld	s1,24(sp)
    80006048:	6942                	ld	s2,16(sp)
    8000604a:	69a2                	ld	s3,8(sp)
    8000604c:	6a02                	ld	s4,0(sp)
    8000604e:	6145                	addi	sp,sp,48
    80006050:	8082                	ret
        printf("ERROR: Ilegal decrease of closed semaphore.\n");
    80006052:	00002517          	auipc	a0,0x2
    80006056:	61650513          	addi	a0,a0,1558 # 80008668 <etext+0x668>
    8000605a:	ffffa097          	auipc	ra,0xffffa
    8000605e:	550080e7          	jalr	1360(ra) # 800005aa <printf>
        release(&(sem_table[sem].lock));
    80006062:	8526                	mv	a0,s1
    80006064:	ffffb097          	auipc	ra,0xffffb
    80006068:	c88080e7          	jalr	-888(ra) # 80000cec <release>
        return SEM_ERROR;
    8000606c:	4501                	li	a0,0
    8000606e:	bfd1                	j	80006042 <sem_down+0x6c>

0000000080006070 <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006070:	1141                	addi	sp,sp,-16
    80006072:	e422                	sd	s0,8(sp)
    80006074:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006076:	0c0007b7          	lui	a5,0xc000
    8000607a:	4705                	li	a4,1
    8000607c:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000607e:	0c0007b7          	lui	a5,0xc000
    80006082:	c3d8                	sw	a4,4(a5)
}
    80006084:	6422                	ld	s0,8(sp)
    80006086:	0141                	addi	sp,sp,16
    80006088:	8082                	ret

000000008000608a <plicinithart>:

void
plicinithart(void)
{
    8000608a:	1141                	addi	sp,sp,-16
    8000608c:	e406                	sd	ra,8(sp)
    8000608e:	e022                	sd	s0,0(sp)
    80006090:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006092:	ffffc097          	auipc	ra,0xffffc
    80006096:	994080e7          	jalr	-1644(ra) # 80001a26 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    8000609a:	0085171b          	slliw	a4,a0,0x8
    8000609e:	0c0027b7          	lui	a5,0xc002
    800060a2:	97ba                	add	a5,a5,a4
    800060a4:	40200713          	li	a4,1026
    800060a8:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060ac:	00d5151b          	slliw	a0,a0,0xd
    800060b0:	0c2017b7          	lui	a5,0xc201
    800060b4:	97aa                	add	a5,a5,a0
    800060b6:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800060ba:	60a2                	ld	ra,8(sp)
    800060bc:	6402                	ld	s0,0(sp)
    800060be:	0141                	addi	sp,sp,16
    800060c0:	8082                	ret

00000000800060c2 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060c2:	1141                	addi	sp,sp,-16
    800060c4:	e406                	sd	ra,8(sp)
    800060c6:	e022                	sd	s0,0(sp)
    800060c8:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060ca:	ffffc097          	auipc	ra,0xffffc
    800060ce:	95c080e7          	jalr	-1700(ra) # 80001a26 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800060d2:	00d5151b          	slliw	a0,a0,0xd
    800060d6:	0c2017b7          	lui	a5,0xc201
    800060da:	97aa                	add	a5,a5,a0
  return irq;
}
    800060dc:	43c8                	lw	a0,4(a5)
    800060de:	60a2                	ld	ra,8(sp)
    800060e0:	6402                	ld	s0,0(sp)
    800060e2:	0141                	addi	sp,sp,16
    800060e4:	8082                	ret

00000000800060e6 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060e6:	1101                	addi	sp,sp,-32
    800060e8:	ec06                	sd	ra,24(sp)
    800060ea:	e822                	sd	s0,16(sp)
    800060ec:	e426                	sd	s1,8(sp)
    800060ee:	1000                	addi	s0,sp,32
    800060f0:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060f2:	ffffc097          	auipc	ra,0xffffc
    800060f6:	934080e7          	jalr	-1740(ra) # 80001a26 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060fa:	00d5151b          	slliw	a0,a0,0xd
    800060fe:	0c2017b7          	lui	a5,0xc201
    80006102:	97aa                	add	a5,a5,a0
    80006104:	c3c4                	sw	s1,4(a5)
}
    80006106:	60e2                	ld	ra,24(sp)
    80006108:	6442                	ld	s0,16(sp)
    8000610a:	64a2                	ld	s1,8(sp)
    8000610c:	6105                	addi	sp,sp,32
    8000610e:	8082                	ret

0000000080006110 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006110:	1141                	addi	sp,sp,-16
    80006112:	e406                	sd	ra,8(sp)
    80006114:	e022                	sd	s0,0(sp)
    80006116:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006118:	479d                	li	a5,7
    8000611a:	04a7cc63          	blt	a5,a0,80006172 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    8000611e:	00020797          	auipc	a5,0x20
    80006122:	61278793          	addi	a5,a5,1554 # 80026730 <disk>
    80006126:	97aa                	add	a5,a5,a0
    80006128:	0187c783          	lbu	a5,24(a5)
    8000612c:	ebb9                	bnez	a5,80006182 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000612e:	00451693          	slli	a3,a0,0x4
    80006132:	00020797          	auipc	a5,0x20
    80006136:	5fe78793          	addi	a5,a5,1534 # 80026730 <disk>
    8000613a:	6398                	ld	a4,0(a5)
    8000613c:	9736                	add	a4,a4,a3
    8000613e:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006142:	6398                	ld	a4,0(a5)
    80006144:	9736                	add	a4,a4,a3
    80006146:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000614a:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000614e:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006152:	97aa                	add	a5,a5,a0
    80006154:	4705                	li	a4,1
    80006156:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000615a:	00020517          	auipc	a0,0x20
    8000615e:	5ee50513          	addi	a0,a0,1518 # 80026748 <disk+0x18>
    80006162:	ffffc097          	auipc	ra,0xffffc
    80006166:	ffe080e7          	jalr	-2(ra) # 80002160 <wakeup>
}
    8000616a:	60a2                	ld	ra,8(sp)
    8000616c:	6402                	ld	s0,0(sp)
    8000616e:	0141                	addi	sp,sp,16
    80006170:	8082                	ret
    panic("free_desc 1");
    80006172:	00002517          	auipc	a0,0x2
    80006176:	52650513          	addi	a0,a0,1318 # 80008698 <etext+0x698>
    8000617a:	ffffa097          	auipc	ra,0xffffa
    8000617e:	3e6080e7          	jalr	998(ra) # 80000560 <panic>
    panic("free_desc 2");
    80006182:	00002517          	auipc	a0,0x2
    80006186:	52650513          	addi	a0,a0,1318 # 800086a8 <etext+0x6a8>
    8000618a:	ffffa097          	auipc	ra,0xffffa
    8000618e:	3d6080e7          	jalr	982(ra) # 80000560 <panic>

0000000080006192 <virtio_disk_init>:
{
    80006192:	1101                	addi	sp,sp,-32
    80006194:	ec06                	sd	ra,24(sp)
    80006196:	e822                	sd	s0,16(sp)
    80006198:	e426                	sd	s1,8(sp)
    8000619a:	e04a                	sd	s2,0(sp)
    8000619c:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000619e:	00002597          	auipc	a1,0x2
    800061a2:	51a58593          	addi	a1,a1,1306 # 800086b8 <etext+0x6b8>
    800061a6:	00020517          	auipc	a0,0x20
    800061aa:	6b250513          	addi	a0,a0,1714 # 80026858 <disk+0x128>
    800061ae:	ffffb097          	auipc	ra,0xffffb
    800061b2:	9fa080e7          	jalr	-1542(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061b6:	100017b7          	lui	a5,0x10001
    800061ba:	4398                	lw	a4,0(a5)
    800061bc:	2701                	sext.w	a4,a4
    800061be:	747277b7          	lui	a5,0x74727
    800061c2:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061c6:	18f71c63          	bne	a4,a5,8000635e <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061ca:	100017b7          	lui	a5,0x10001
    800061ce:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800061d0:	439c                	lw	a5,0(a5)
    800061d2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061d4:	4709                	li	a4,2
    800061d6:	18e79463          	bne	a5,a4,8000635e <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061da:	100017b7          	lui	a5,0x10001
    800061de:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800061e0:	439c                	lw	a5,0(a5)
    800061e2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800061e4:	16e79d63          	bne	a5,a4,8000635e <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061e8:	100017b7          	lui	a5,0x10001
    800061ec:	47d8                	lw	a4,12(a5)
    800061ee:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061f0:	554d47b7          	lui	a5,0x554d4
    800061f4:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061f8:	16f71363          	bne	a4,a5,8000635e <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061fc:	100017b7          	lui	a5,0x10001
    80006200:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006204:	4705                	li	a4,1
    80006206:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006208:	470d                	li	a4,3
    8000620a:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000620c:	10001737          	lui	a4,0x10001
    80006210:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006212:	c7ffe737          	lui	a4,0xc7ffe
    80006216:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd7eef>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000621a:	8ef9                	and	a3,a3,a4
    8000621c:	10001737          	lui	a4,0x10001
    80006220:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006222:	472d                	li	a4,11
    80006224:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006226:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000622a:	439c                	lw	a5,0(a5)
    8000622c:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006230:	8ba1                	andi	a5,a5,8
    80006232:	12078e63          	beqz	a5,8000636e <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006236:	100017b7          	lui	a5,0x10001
    8000623a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000623e:	100017b7          	lui	a5,0x10001
    80006242:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006246:	439c                	lw	a5,0(a5)
    80006248:	2781                	sext.w	a5,a5
    8000624a:	12079a63          	bnez	a5,8000637e <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000624e:	100017b7          	lui	a5,0x10001
    80006252:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006256:	439c                	lw	a5,0(a5)
    80006258:	2781                	sext.w	a5,a5
  if(max == 0)
    8000625a:	12078a63          	beqz	a5,8000638e <virtio_disk_init+0x1fc>
  if(max < NUM)
    8000625e:	471d                	li	a4,7
    80006260:	12f77f63          	bgeu	a4,a5,8000639e <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    80006264:	ffffb097          	auipc	ra,0xffffb
    80006268:	8e4080e7          	jalr	-1820(ra) # 80000b48 <kalloc>
    8000626c:	00020497          	auipc	s1,0x20
    80006270:	4c448493          	addi	s1,s1,1220 # 80026730 <disk>
    80006274:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006276:	ffffb097          	auipc	ra,0xffffb
    8000627a:	8d2080e7          	jalr	-1838(ra) # 80000b48 <kalloc>
    8000627e:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006280:	ffffb097          	auipc	ra,0xffffb
    80006284:	8c8080e7          	jalr	-1848(ra) # 80000b48 <kalloc>
    80006288:	87aa                	mv	a5,a0
    8000628a:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000628c:	6088                	ld	a0,0(s1)
    8000628e:	12050063          	beqz	a0,800063ae <virtio_disk_init+0x21c>
    80006292:	00020717          	auipc	a4,0x20
    80006296:	4a673703          	ld	a4,1190(a4) # 80026738 <disk+0x8>
    8000629a:	10070a63          	beqz	a4,800063ae <virtio_disk_init+0x21c>
    8000629e:	10078863          	beqz	a5,800063ae <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    800062a2:	6605                	lui	a2,0x1
    800062a4:	4581                	li	a1,0
    800062a6:	ffffb097          	auipc	ra,0xffffb
    800062aa:	a8e080e7          	jalr	-1394(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    800062ae:	00020497          	auipc	s1,0x20
    800062b2:	48248493          	addi	s1,s1,1154 # 80026730 <disk>
    800062b6:	6605                	lui	a2,0x1
    800062b8:	4581                	li	a1,0
    800062ba:	6488                	ld	a0,8(s1)
    800062bc:	ffffb097          	auipc	ra,0xffffb
    800062c0:	a78080e7          	jalr	-1416(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    800062c4:	6605                	lui	a2,0x1
    800062c6:	4581                	li	a1,0
    800062c8:	6888                	ld	a0,16(s1)
    800062ca:	ffffb097          	auipc	ra,0xffffb
    800062ce:	a6a080e7          	jalr	-1430(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800062d2:	100017b7          	lui	a5,0x10001
    800062d6:	4721                	li	a4,8
    800062d8:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800062da:	4098                	lw	a4,0(s1)
    800062dc:	100017b7          	lui	a5,0x10001
    800062e0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800062e4:	40d8                	lw	a4,4(s1)
    800062e6:	100017b7          	lui	a5,0x10001
    800062ea:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800062ee:	649c                	ld	a5,8(s1)
    800062f0:	0007869b          	sext.w	a3,a5
    800062f4:	10001737          	lui	a4,0x10001
    800062f8:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800062fc:	9781                	srai	a5,a5,0x20
    800062fe:	10001737          	lui	a4,0x10001
    80006302:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006306:	689c                	ld	a5,16(s1)
    80006308:	0007869b          	sext.w	a3,a5
    8000630c:	10001737          	lui	a4,0x10001
    80006310:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006314:	9781                	srai	a5,a5,0x20
    80006316:	10001737          	lui	a4,0x10001
    8000631a:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000631e:	10001737          	lui	a4,0x10001
    80006322:	4785                	li	a5,1
    80006324:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006326:	00f48c23          	sb	a5,24(s1)
    8000632a:	00f48ca3          	sb	a5,25(s1)
    8000632e:	00f48d23          	sb	a5,26(s1)
    80006332:	00f48da3          	sb	a5,27(s1)
    80006336:	00f48e23          	sb	a5,28(s1)
    8000633a:	00f48ea3          	sb	a5,29(s1)
    8000633e:	00f48f23          	sb	a5,30(s1)
    80006342:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006346:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000634a:	100017b7          	lui	a5,0x10001
    8000634e:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80006352:	60e2                	ld	ra,24(sp)
    80006354:	6442                	ld	s0,16(sp)
    80006356:	64a2                	ld	s1,8(sp)
    80006358:	6902                	ld	s2,0(sp)
    8000635a:	6105                	addi	sp,sp,32
    8000635c:	8082                	ret
    panic("could not find virtio disk");
    8000635e:	00002517          	auipc	a0,0x2
    80006362:	36a50513          	addi	a0,a0,874 # 800086c8 <etext+0x6c8>
    80006366:	ffffa097          	auipc	ra,0xffffa
    8000636a:	1fa080e7          	jalr	506(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    8000636e:	00002517          	auipc	a0,0x2
    80006372:	37a50513          	addi	a0,a0,890 # 800086e8 <etext+0x6e8>
    80006376:	ffffa097          	auipc	ra,0xffffa
    8000637a:	1ea080e7          	jalr	490(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    8000637e:	00002517          	auipc	a0,0x2
    80006382:	38a50513          	addi	a0,a0,906 # 80008708 <etext+0x708>
    80006386:	ffffa097          	auipc	ra,0xffffa
    8000638a:	1da080e7          	jalr	474(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    8000638e:	00002517          	auipc	a0,0x2
    80006392:	39a50513          	addi	a0,a0,922 # 80008728 <etext+0x728>
    80006396:	ffffa097          	auipc	ra,0xffffa
    8000639a:	1ca080e7          	jalr	458(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    8000639e:	00002517          	auipc	a0,0x2
    800063a2:	3aa50513          	addi	a0,a0,938 # 80008748 <etext+0x748>
    800063a6:	ffffa097          	auipc	ra,0xffffa
    800063aa:	1ba080e7          	jalr	442(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    800063ae:	00002517          	auipc	a0,0x2
    800063b2:	3ba50513          	addi	a0,a0,954 # 80008768 <etext+0x768>
    800063b6:	ffffa097          	auipc	ra,0xffffa
    800063ba:	1aa080e7          	jalr	426(ra) # 80000560 <panic>

00000000800063be <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063be:	7159                	addi	sp,sp,-112
    800063c0:	f486                	sd	ra,104(sp)
    800063c2:	f0a2                	sd	s0,96(sp)
    800063c4:	eca6                	sd	s1,88(sp)
    800063c6:	e8ca                	sd	s2,80(sp)
    800063c8:	e4ce                	sd	s3,72(sp)
    800063ca:	e0d2                	sd	s4,64(sp)
    800063cc:	fc56                	sd	s5,56(sp)
    800063ce:	f85a                	sd	s6,48(sp)
    800063d0:	f45e                	sd	s7,40(sp)
    800063d2:	f062                	sd	s8,32(sp)
    800063d4:	ec66                	sd	s9,24(sp)
    800063d6:	1880                	addi	s0,sp,112
    800063d8:	8a2a                	mv	s4,a0
    800063da:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800063dc:	00c52c83          	lw	s9,12(a0)
    800063e0:	001c9c9b          	slliw	s9,s9,0x1
    800063e4:	1c82                	slli	s9,s9,0x20
    800063e6:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800063ea:	00020517          	auipc	a0,0x20
    800063ee:	46e50513          	addi	a0,a0,1134 # 80026858 <disk+0x128>
    800063f2:	ffffb097          	auipc	ra,0xffffb
    800063f6:	846080e7          	jalr	-1978(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    800063fa:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800063fc:	44a1                	li	s1,8
      disk.free[i] = 0;
    800063fe:	00020b17          	auipc	s6,0x20
    80006402:	332b0b13          	addi	s6,s6,818 # 80026730 <disk>
  for(int i = 0; i < 3; i++){
    80006406:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006408:	00020c17          	auipc	s8,0x20
    8000640c:	450c0c13          	addi	s8,s8,1104 # 80026858 <disk+0x128>
    80006410:	a0ad                	j	8000647a <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80006412:	00fb0733          	add	a4,s6,a5
    80006416:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    8000641a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000641c:	0207c563          	bltz	a5,80006446 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006420:	2905                	addiw	s2,s2,1
    80006422:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006424:	05590f63          	beq	s2,s5,80006482 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006428:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000642a:	00020717          	auipc	a4,0x20
    8000642e:	30670713          	addi	a4,a4,774 # 80026730 <disk>
    80006432:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006434:	01874683          	lbu	a3,24(a4)
    80006438:	fee9                	bnez	a3,80006412 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    8000643a:	2785                	addiw	a5,a5,1
    8000643c:	0705                	addi	a4,a4,1
    8000643e:	fe979be3          	bne	a5,s1,80006434 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006442:	57fd                	li	a5,-1
    80006444:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006446:	03205163          	blez	s2,80006468 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    8000644a:	f9042503          	lw	a0,-112(s0)
    8000644e:	00000097          	auipc	ra,0x0
    80006452:	cc2080e7          	jalr	-830(ra) # 80006110 <free_desc>
      for(int j = 0; j < i; j++)
    80006456:	4785                	li	a5,1
    80006458:	0127d863          	bge	a5,s2,80006468 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    8000645c:	f9442503          	lw	a0,-108(s0)
    80006460:	00000097          	auipc	ra,0x0
    80006464:	cb0080e7          	jalr	-848(ra) # 80006110 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006468:	85e2                	mv	a1,s8
    8000646a:	00020517          	auipc	a0,0x20
    8000646e:	2de50513          	addi	a0,a0,734 # 80026748 <disk+0x18>
    80006472:	ffffc097          	auipc	ra,0xffffc
    80006476:	c8a080e7          	jalr	-886(ra) # 800020fc <sleep>
  for(int i = 0; i < 3; i++){
    8000647a:	f9040613          	addi	a2,s0,-112
    8000647e:	894e                	mv	s2,s3
    80006480:	b765                	j	80006428 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006482:	f9042503          	lw	a0,-112(s0)
    80006486:	00451693          	slli	a3,a0,0x4

  if(write)
    8000648a:	00020797          	auipc	a5,0x20
    8000648e:	2a678793          	addi	a5,a5,678 # 80026730 <disk>
    80006492:	00a50713          	addi	a4,a0,10
    80006496:	0712                	slli	a4,a4,0x4
    80006498:	973e                	add	a4,a4,a5
    8000649a:	01703633          	snez	a2,s7
    8000649e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800064a0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800064a4:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800064a8:	6398                	ld	a4,0(a5)
    800064aa:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064ac:	0a868613          	addi	a2,a3,168
    800064b0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064b2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064b4:	6390                	ld	a2,0(a5)
    800064b6:	00d605b3          	add	a1,a2,a3
    800064ba:	4741                	li	a4,16
    800064bc:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064be:	4805                	li	a6,1
    800064c0:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800064c4:	f9442703          	lw	a4,-108(s0)
    800064c8:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800064cc:	0712                	slli	a4,a4,0x4
    800064ce:	963a                	add	a2,a2,a4
    800064d0:	058a0593          	addi	a1,s4,88
    800064d4:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800064d6:	0007b883          	ld	a7,0(a5)
    800064da:	9746                	add	a4,a4,a7
    800064dc:	40000613          	li	a2,1024
    800064e0:	c710                	sw	a2,8(a4)
  if(write)
    800064e2:	001bb613          	seqz	a2,s7
    800064e6:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800064ea:	00166613          	ori	a2,a2,1
    800064ee:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800064f2:	f9842583          	lw	a1,-104(s0)
    800064f6:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064fa:	00250613          	addi	a2,a0,2
    800064fe:	0612                	slli	a2,a2,0x4
    80006500:	963e                	add	a2,a2,a5
    80006502:	577d                	li	a4,-1
    80006504:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006508:	0592                	slli	a1,a1,0x4
    8000650a:	98ae                	add	a7,a7,a1
    8000650c:	03068713          	addi	a4,a3,48
    80006510:	973e                	add	a4,a4,a5
    80006512:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006516:	6398                	ld	a4,0(a5)
    80006518:	972e                	add	a4,a4,a1
    8000651a:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000651e:	4689                	li	a3,2
    80006520:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006524:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006528:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000652c:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006530:	6794                	ld	a3,8(a5)
    80006532:	0026d703          	lhu	a4,2(a3)
    80006536:	8b1d                	andi	a4,a4,7
    80006538:	0706                	slli	a4,a4,0x1
    8000653a:	96ba                	add	a3,a3,a4
    8000653c:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006540:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006544:	6798                	ld	a4,8(a5)
    80006546:	00275783          	lhu	a5,2(a4)
    8000654a:	2785                	addiw	a5,a5,1
    8000654c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006550:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006554:	100017b7          	lui	a5,0x10001
    80006558:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000655c:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006560:	00020917          	auipc	s2,0x20
    80006564:	2f890913          	addi	s2,s2,760 # 80026858 <disk+0x128>
  while(b->disk == 1) {
    80006568:	4485                	li	s1,1
    8000656a:	01079c63          	bne	a5,a6,80006582 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000656e:	85ca                	mv	a1,s2
    80006570:	8552                	mv	a0,s4
    80006572:	ffffc097          	auipc	ra,0xffffc
    80006576:	b8a080e7          	jalr	-1142(ra) # 800020fc <sleep>
  while(b->disk == 1) {
    8000657a:	004a2783          	lw	a5,4(s4)
    8000657e:	fe9788e3          	beq	a5,s1,8000656e <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006582:	f9042903          	lw	s2,-112(s0)
    80006586:	00290713          	addi	a4,s2,2
    8000658a:	0712                	slli	a4,a4,0x4
    8000658c:	00020797          	auipc	a5,0x20
    80006590:	1a478793          	addi	a5,a5,420 # 80026730 <disk>
    80006594:	97ba                	add	a5,a5,a4
    80006596:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000659a:	00020997          	auipc	s3,0x20
    8000659e:	19698993          	addi	s3,s3,406 # 80026730 <disk>
    800065a2:	00491713          	slli	a4,s2,0x4
    800065a6:	0009b783          	ld	a5,0(s3)
    800065aa:	97ba                	add	a5,a5,a4
    800065ac:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800065b0:	854a                	mv	a0,s2
    800065b2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800065b6:	00000097          	auipc	ra,0x0
    800065ba:	b5a080e7          	jalr	-1190(ra) # 80006110 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800065be:	8885                	andi	s1,s1,1
    800065c0:	f0ed                	bnez	s1,800065a2 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800065c2:	00020517          	auipc	a0,0x20
    800065c6:	29650513          	addi	a0,a0,662 # 80026858 <disk+0x128>
    800065ca:	ffffa097          	auipc	ra,0xffffa
    800065ce:	722080e7          	jalr	1826(ra) # 80000cec <release>
}
    800065d2:	70a6                	ld	ra,104(sp)
    800065d4:	7406                	ld	s0,96(sp)
    800065d6:	64e6                	ld	s1,88(sp)
    800065d8:	6946                	ld	s2,80(sp)
    800065da:	69a6                	ld	s3,72(sp)
    800065dc:	6a06                	ld	s4,64(sp)
    800065de:	7ae2                	ld	s5,56(sp)
    800065e0:	7b42                	ld	s6,48(sp)
    800065e2:	7ba2                	ld	s7,40(sp)
    800065e4:	7c02                	ld	s8,32(sp)
    800065e6:	6ce2                	ld	s9,24(sp)
    800065e8:	6165                	addi	sp,sp,112
    800065ea:	8082                	ret

00000000800065ec <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065ec:	1101                	addi	sp,sp,-32
    800065ee:	ec06                	sd	ra,24(sp)
    800065f0:	e822                	sd	s0,16(sp)
    800065f2:	e426                	sd	s1,8(sp)
    800065f4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800065f6:	00020497          	auipc	s1,0x20
    800065fa:	13a48493          	addi	s1,s1,314 # 80026730 <disk>
    800065fe:	00020517          	auipc	a0,0x20
    80006602:	25a50513          	addi	a0,a0,602 # 80026858 <disk+0x128>
    80006606:	ffffa097          	auipc	ra,0xffffa
    8000660a:	632080e7          	jalr	1586(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000660e:	100017b7          	lui	a5,0x10001
    80006612:	53b8                	lw	a4,96(a5)
    80006614:	8b0d                	andi	a4,a4,3
    80006616:	100017b7          	lui	a5,0x10001
    8000661a:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000661c:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006620:	689c                	ld	a5,16(s1)
    80006622:	0204d703          	lhu	a4,32(s1)
    80006626:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000662a:	04f70863          	beq	a4,a5,8000667a <virtio_disk_intr+0x8e>
    __sync_synchronize();
    8000662e:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006632:	6898                	ld	a4,16(s1)
    80006634:	0204d783          	lhu	a5,32(s1)
    80006638:	8b9d                	andi	a5,a5,7
    8000663a:	078e                	slli	a5,a5,0x3
    8000663c:	97ba                	add	a5,a5,a4
    8000663e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006640:	00278713          	addi	a4,a5,2
    80006644:	0712                	slli	a4,a4,0x4
    80006646:	9726                	add	a4,a4,s1
    80006648:	01074703          	lbu	a4,16(a4)
    8000664c:	e721                	bnez	a4,80006694 <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000664e:	0789                	addi	a5,a5,2
    80006650:	0792                	slli	a5,a5,0x4
    80006652:	97a6                	add	a5,a5,s1
    80006654:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006656:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000665a:	ffffc097          	auipc	ra,0xffffc
    8000665e:	b06080e7          	jalr	-1274(ra) # 80002160 <wakeup>

    disk.used_idx += 1;
    80006662:	0204d783          	lhu	a5,32(s1)
    80006666:	2785                	addiw	a5,a5,1
    80006668:	17c2                	slli	a5,a5,0x30
    8000666a:	93c1                	srli	a5,a5,0x30
    8000666c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006670:	6898                	ld	a4,16(s1)
    80006672:	00275703          	lhu	a4,2(a4)
    80006676:	faf71ce3          	bne	a4,a5,8000662e <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    8000667a:	00020517          	auipc	a0,0x20
    8000667e:	1de50513          	addi	a0,a0,478 # 80026858 <disk+0x128>
    80006682:	ffffa097          	auipc	ra,0xffffa
    80006686:	66a080e7          	jalr	1642(ra) # 80000cec <release>
}
    8000668a:	60e2                	ld	ra,24(sp)
    8000668c:	6442                	ld	s0,16(sp)
    8000668e:	64a2                	ld	s1,8(sp)
    80006690:	6105                	addi	sp,sp,32
    80006692:	8082                	ret
      panic("virtio_disk_intr status");
    80006694:	00002517          	auipc	a0,0x2
    80006698:	0ec50513          	addi	a0,a0,236 # 80008780 <etext+0x780>
    8000669c:	ffffa097          	auipc	ra,0xffffa
    800066a0:	ec4080e7          	jalr	-316(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
