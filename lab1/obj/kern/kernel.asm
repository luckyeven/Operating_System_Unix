
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6c 00 00 00       	call   f01000aa <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	e8 7e 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010004e:	81 c3 ba 12 01 00    	add    $0x112ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 d8 07 ff ff    	lea    -0xf828(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 26 0a 00 00       	call   f0100a8d <cprintf>
	if (x > 0)
f0100067:	83 c4 10             	add    $0x10,%esp
f010006a:	85 f6                	test   %esi,%esi
f010006c:	7e 29                	jle    f0100097 <test_backtrace+0x57>
		test_backtrace(x-1);
f010006e:	83 ec 0c             	sub    $0xc,%esp
f0100071:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100074:	50                   	push   %eax
f0100075:	e8 c6 ff ff ff       	call   f0100040 <test_backtrace>
f010007a:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f010007d:	83 ec 08             	sub    $0x8,%esp
f0100080:	56                   	push   %esi
f0100081:	8d 83 f4 07 ff ff    	lea    -0xf80c(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 00 0a 00 00       	call   f0100a8d <cprintf>
}
f010008d:	83 c4 10             	add    $0x10,%esp
f0100090:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100093:	5b                   	pop    %ebx
f0100094:	5e                   	pop    %esi
f0100095:	5d                   	pop    %ebp
f0100096:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100097:	83 ec 04             	sub    $0x4,%esp
f010009a:	6a 00                	push   $0x0
f010009c:	6a 00                	push   $0x0
f010009e:	6a 00                	push   $0x0
f01000a0:	e8 0c 08 00 00       	call   f01008b1 <mon_backtrace>
f01000a5:	83 c4 10             	add    $0x10,%esp
f01000a8:	eb d3                	jmp    f010007d <test_backtrace+0x3d>

f01000aa <i386_init>:

void
i386_init(void)
{
f01000aa:	f3 0f 1e fb          	endbr32 
f01000ae:	55                   	push   %ebp
f01000af:	89 e5                	mov    %esp,%ebp
f01000b1:	53                   	push   %ebx
f01000b2:	83 ec 08             	sub    $0x8,%esp
f01000b5:	e8 12 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f01000ba:	81 c3 4e 12 01 00    	add    $0x1124e,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000c0:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000c6:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000cc:	29 d0                	sub    %edx,%eax
f01000ce:	50                   	push   %eax
f01000cf:	6a 00                	push   $0x0
f01000d1:	52                   	push   %edx
f01000d2:	e8 89 15 00 00       	call   f0101660 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d7:	e8 4b 05 00 00       	call   f0100627 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000dc:	83 c4 08             	add    $0x8,%esp
f01000df:	68 ac 1a 00 00       	push   $0x1aac
f01000e4:	8d 83 0f 08 ff ff    	lea    -0xf7f1(%ebx),%eax
f01000ea:	50                   	push   %eax
f01000eb:	e8 9d 09 00 00       	call   f0100a8d <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000f0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000f7:	e8 44 ff ff ff       	call   f0100040 <test_backtrace>
f01000fc:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ff:	83 ec 0c             	sub    $0xc,%esp
f0100102:	6a 00                	push   $0x0
f0100104:	e8 b2 07 00 00       	call   f01008bb <monitor>
f0100109:	83 c4 10             	add    $0x10,%esp
f010010c:	eb f1                	jmp    f01000ff <i386_init+0x55>

f010010e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010010e:	f3 0f 1e fb          	endbr32 
f0100112:	55                   	push   %ebp
f0100113:	89 e5                	mov    %esp,%ebp
f0100115:	57                   	push   %edi
f0100116:	56                   	push   %esi
f0100117:	53                   	push   %ebx
f0100118:	83 ec 0c             	sub    $0xc,%esp
f010011b:	e8 ac 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100120:	81 c3 e8 11 01 00    	add    $0x111e8,%ebx
f0100126:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100129:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f010012f:	83 38 00             	cmpl   $0x0,(%eax)
f0100132:	74 0f                	je     f0100143 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100134:	83 ec 0c             	sub    $0xc,%esp
f0100137:	6a 00                	push   $0x0
f0100139:	e8 7d 07 00 00       	call   f01008bb <monitor>
f010013e:	83 c4 10             	add    $0x10,%esp
f0100141:	eb f1                	jmp    f0100134 <_panic+0x26>
	panicstr = fmt;
f0100143:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100145:	fa                   	cli    
f0100146:	fc                   	cld    
	va_start(ap, fmt);
f0100147:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010014a:	83 ec 04             	sub    $0x4,%esp
f010014d:	ff 75 0c             	pushl  0xc(%ebp)
f0100150:	ff 75 08             	pushl  0x8(%ebp)
f0100153:	8d 83 2a 08 ff ff    	lea    -0xf7d6(%ebx),%eax
f0100159:	50                   	push   %eax
f010015a:	e8 2e 09 00 00       	call   f0100a8d <cprintf>
	vcprintf(fmt, ap);
f010015f:	83 c4 08             	add    $0x8,%esp
f0100162:	56                   	push   %esi
f0100163:	57                   	push   %edi
f0100164:	e8 e9 08 00 00       	call   f0100a52 <vcprintf>
	cprintf("\n");
f0100169:	8d 83 66 08 ff ff    	lea    -0xf79a(%ebx),%eax
f010016f:	89 04 24             	mov    %eax,(%esp)
f0100172:	e8 16 09 00 00       	call   f0100a8d <cprintf>
f0100177:	83 c4 10             	add    $0x10,%esp
f010017a:	eb b8                	jmp    f0100134 <_panic+0x26>

f010017c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010017c:	f3 0f 1e fb          	endbr32 
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp
f0100183:	56                   	push   %esi
f0100184:	53                   	push   %ebx
f0100185:	e8 42 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010018a:	81 c3 7e 11 01 00    	add    $0x1117e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100190:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100193:	83 ec 04             	sub    $0x4,%esp
f0100196:	ff 75 0c             	pushl  0xc(%ebp)
f0100199:	ff 75 08             	pushl  0x8(%ebp)
f010019c:	8d 83 42 08 ff ff    	lea    -0xf7be(%ebx),%eax
f01001a2:	50                   	push   %eax
f01001a3:	e8 e5 08 00 00       	call   f0100a8d <cprintf>
	vcprintf(fmt, ap);
f01001a8:	83 c4 08             	add    $0x8,%esp
f01001ab:	56                   	push   %esi
f01001ac:	ff 75 10             	pushl  0x10(%ebp)
f01001af:	e8 9e 08 00 00       	call   f0100a52 <vcprintf>
	cprintf("\n");
f01001b4:	8d 83 66 08 ff ff    	lea    -0xf79a(%ebx),%eax
f01001ba:	89 04 24             	mov    %eax,(%esp)
f01001bd:	e8 cb 08 00 00       	call   f0100a8d <cprintf>
	va_end(ap);
}
f01001c2:	83 c4 10             	add    $0x10,%esp
f01001c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c8:	5b                   	pop    %ebx
f01001c9:	5e                   	pop    %esi
f01001ca:	5d                   	pop    %ebp
f01001cb:	c3                   	ret    

f01001cc <__x86.get_pc_thunk.bx>:
f01001cc:	8b 1c 24             	mov    (%esp),%ebx
f01001cf:	c3                   	ret    

f01001d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001d0:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001d4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d9:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001da:	a8 01                	test   $0x1,%al
f01001dc:	74 0a                	je     f01001e8 <serial_proc_data+0x18>
f01001de:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e3:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001e4:	0f b6 c0             	movzbl %al,%eax
f01001e7:	c3                   	ret    
		return -1;
f01001e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001ed:	c3                   	ret    

f01001ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ee:	55                   	push   %ebp
f01001ef:	89 e5                	mov    %esp,%ebp
f01001f1:	57                   	push   %edi
f01001f2:	56                   	push   %esi
f01001f3:	53                   	push   %ebx
f01001f4:	83 ec 1c             	sub    $0x1c,%esp
f01001f7:	e8 88 05 00 00       	call   f0100784 <__x86.get_pc_thunk.si>
f01001fc:	81 c6 0c 11 01 00    	add    $0x1110c,%esi
f0100202:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100204:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f010020a:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010020d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100210:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100213:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100216:	ff d0                	call   *%eax
f0100218:	83 f8 ff             	cmp    $0xffffffff,%eax
f010021b:	74 2b                	je     f0100248 <cons_intr+0x5a>
		if (c == 0)
f010021d:	85 c0                	test   %eax,%eax
f010021f:	74 f2                	je     f0100213 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f0100221:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100228:	8d 51 01             	lea    0x1(%ecx),%edx
f010022b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010022e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100231:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	0f 44 d0             	cmove  %eax,%edx
f010023f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100246:	eb cb                	jmp    f0100213 <cons_intr+0x25>
	}
}
f0100248:	83 c4 1c             	add    $0x1c,%esp
f010024b:	5b                   	pop    %ebx
f010024c:	5e                   	pop    %esi
f010024d:	5f                   	pop    %edi
f010024e:	5d                   	pop    %ebp
f010024f:	c3                   	ret    

f0100250 <kbd_proc_data>:
{
f0100250:	f3 0f 1e fb          	endbr32 
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	56                   	push   %esi
f0100258:	53                   	push   %ebx
f0100259:	e8 6e ff ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010025e:	81 c3 aa 10 01 00    	add    $0x110aa,%ebx
f0100264:	ba 64 00 00 00       	mov    $0x64,%edx
f0100269:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010026a:	a8 01                	test   $0x1,%al
f010026c:	0f 84 fb 00 00 00    	je     f010036d <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100272:	a8 20                	test   $0x20,%al
f0100274:	0f 85 fa 00 00 00    	jne    f0100374 <kbd_proc_data+0x124>
f010027a:	ba 60 00 00 00       	mov    $0x60,%edx
f010027f:	ec                   	in     (%dx),%al
f0100280:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100282:	3c e0                	cmp    $0xe0,%al
f0100284:	74 64                	je     f01002ea <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100286:	84 c0                	test   %al,%al
f0100288:	78 75                	js     f01002ff <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f010028a:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100290:	f6 c1 40             	test   $0x40,%cl
f0100293:	74 0e                	je     f01002a3 <kbd_proc_data+0x53>
		data |= 0x80;
f0100295:	83 c8 80             	or     $0xffffff80,%eax
f0100298:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010029a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010029d:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 98 09 ff 	movzbl -0xf668(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f01002b4:	0f b6 8c 13 98 08 ff 	movzbl -0xf768(%ebx,%edx,1),%ecx
f01002bb:	ff 
f01002bc:	31 c8                	xor    %ecx,%eax
f01002be:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002c4:	89 c1                	mov    %eax,%ecx
f01002c6:	83 e1 03             	and    $0x3,%ecx
f01002c9:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002d0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002d4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002d7:	a8 08                	test   $0x8,%al
f01002d9:	74 65                	je     f0100340 <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01002db:	89 f2                	mov    %esi,%edx
f01002dd:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002e0:	83 f9 19             	cmp    $0x19,%ecx
f01002e3:	77 4f                	ja     f0100334 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01002e5:	83 ee 20             	sub    $0x20,%esi
f01002e8:	eb 0c                	jmp    f01002f6 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002ea:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002f1:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002f6:	89 f0                	mov    %esi,%eax
f01002f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002fb:	5b                   	pop    %ebx
f01002fc:	5e                   	pop    %esi
f01002fd:	5d                   	pop    %ebp
f01002fe:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100305:	89 ce                	mov    %ecx,%esi
f0100307:	83 e6 40             	and    $0x40,%esi
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 f6                	test   %esi,%esi
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 84 13 98 09 ff 	movzbl -0xf668(%ebx,%edx,1),%eax
f010031c:	ff 
f010031d:	83 c8 40             	or     $0x40,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	f7 d0                	not    %eax
f0100325:	21 c8                	and    %ecx,%eax
f0100327:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f010032d:	be 00 00 00 00       	mov    $0x0,%esi
f0100332:	eb c2                	jmp    f01002f6 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100334:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100337:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033a:	83 fa 1a             	cmp    $0x1a,%edx
f010033d:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100340:	f7 d0                	not    %eax
f0100342:	a8 06                	test   $0x6,%al
f0100344:	75 b0                	jne    f01002f6 <kbd_proc_data+0xa6>
f0100346:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010034c:	75 a8                	jne    f01002f6 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010034e:	83 ec 0c             	sub    $0xc,%esp
f0100351:	8d 83 5c 08 ff ff    	lea    -0xf7a4(%ebx),%eax
f0100357:	50                   	push   %eax
f0100358:	e8 30 07 00 00       	call   f0100a8d <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100362:	ba 92 00 00 00       	mov    $0x92,%edx
f0100367:	ee                   	out    %al,(%dx)
}
f0100368:	83 c4 10             	add    $0x10,%esp
f010036b:	eb 89                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f010036d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100372:	eb 82                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f0100374:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100379:	e9 78 ff ff ff       	jmp    f01002f6 <kbd_proc_data+0xa6>

f010037e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010037e:	55                   	push   %ebp
f010037f:	89 e5                	mov    %esp,%ebp
f0100381:	57                   	push   %edi
f0100382:	56                   	push   %esi
f0100383:	53                   	push   %ebx
f0100384:	83 ec 1c             	sub    $0x1c,%esp
f0100387:	e8 40 fe ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010038c:	81 c3 7c 0f 01 00    	add    $0x10f7c,%ebx
f0100392:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100394:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100399:	b9 84 00 00 00       	mov    $0x84,%ecx
f010039e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003a3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a4:	a8 20                	test   $0x20,%al
f01003a6:	75 13                	jne    f01003bb <cons_putc+0x3d>
f01003a8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ae:	7f 0b                	jg     f01003bb <cons_putc+0x3d>
f01003b0:	89 ca                	mov    %ecx,%edx
f01003b2:	ec                   	in     (%dx),%al
f01003b3:	ec                   	in     (%dx),%al
f01003b4:	ec                   	in     (%dx),%al
f01003b5:	ec                   	in     (%dx),%al
	     i++)
f01003b6:	83 c6 01             	add    $0x1,%esi
f01003b9:	eb e3                	jmp    f010039e <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003bb:	89 f8                	mov    %edi,%eax
f01003bd:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003c5:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003c6:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d0:	ba 79 03 00 00       	mov    $0x379,%edx
f01003d5:	ec                   	in     (%dx),%al
f01003d6:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003dc:	7f 0f                	jg     f01003ed <cons_putc+0x6f>
f01003de:	84 c0                	test   %al,%al
f01003e0:	78 0b                	js     f01003ed <cons_putc+0x6f>
f01003e2:	89 ca                	mov    %ecx,%edx
f01003e4:	ec                   	in     (%dx),%al
f01003e5:	ec                   	in     (%dx),%al
f01003e6:	ec                   	in     (%dx),%al
f01003e7:	ec                   	in     (%dx),%al
f01003e8:	83 c6 01             	add    $0x1,%esi
f01003eb:	eb e3                	jmp    f01003d0 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ed:	ba 78 03 00 00       	mov    $0x378,%edx
f01003f2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003f6:	ee                   	out    %al,(%dx)
f01003f7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003fc:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100401:	ee                   	out    %al,(%dx)
f0100402:	b8 08 00 00 00       	mov    $0x8,%eax
f0100407:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100408:	89 f8                	mov    %edi,%eax
f010040a:	80 cc 07             	or     $0x7,%ah
f010040d:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100413:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100416:	89 f8                	mov    %edi,%eax
f0100418:	0f b6 c0             	movzbl %al,%eax
f010041b:	89 f9                	mov    %edi,%ecx
f010041d:	80 f9 0a             	cmp    $0xa,%cl
f0100420:	0f 84 e2 00 00 00    	je     f0100508 <cons_putc+0x18a>
f0100426:	83 f8 0a             	cmp    $0xa,%eax
f0100429:	7f 46                	jg     f0100471 <cons_putc+0xf3>
f010042b:	83 f8 08             	cmp    $0x8,%eax
f010042e:	0f 84 a8 00 00 00    	je     f01004dc <cons_putc+0x15e>
f0100434:	83 f8 09             	cmp    $0x9,%eax
f0100437:	0f 85 d8 00 00 00    	jne    f0100515 <cons_putc+0x197>
		cons_putc(' ');
f010043d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100442:	e8 37 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100447:	b8 20 00 00 00       	mov    $0x20,%eax
f010044c:	e8 2d ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 23 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f010045b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100460:	e8 19 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100465:	b8 20 00 00 00       	mov    $0x20,%eax
f010046a:	e8 0f ff ff ff       	call   f010037e <cons_putc>
		break;
f010046f:	eb 26                	jmp    f0100497 <cons_putc+0x119>
	switch (c & 0xff) {
f0100471:	83 f8 0d             	cmp    $0xd,%eax
f0100474:	0f 85 9b 00 00 00    	jne    f0100515 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f010047a:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100481:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100487:	c1 e8 16             	shr    $0x16,%eax
f010048a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010048d:	c1 e0 04             	shl    $0x4,%eax
f0100490:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100497:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010049e:	cf 07 
f01004a0:	0f 87 92 00 00 00    	ja     f0100538 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f01004a6:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01004ac:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b1:	89 ca                	mov    %ecx,%edx
f01004b3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b4:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01004bb:	8d 71 01             	lea    0x1(%ecx),%esi
f01004be:	89 d8                	mov    %ebx,%eax
f01004c0:	66 c1 e8 08          	shr    $0x8,%ax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
f01004c7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cc:	89 ca                	mov    %ecx,%edx
f01004ce:	ee                   	out    %al,(%dx)
f01004cf:	89 d8                	mov    %ebx,%eax
f01004d1:	89 f2                	mov    %esi,%edx
f01004d3:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d7:	5b                   	pop    %ebx
f01004d8:	5e                   	pop    %esi
f01004d9:	5f                   	pop    %edi
f01004da:	5d                   	pop    %ebp
f01004db:	c3                   	ret    
		if (crt_pos > 0) {
f01004dc:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004e3:	66 85 c0             	test   %ax,%ax
f01004e6:	74 be                	je     f01004a6 <cons_putc+0x128>
			crt_pos--;
f01004e8:	83 e8 01             	sub    $0x1,%eax
f01004eb:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f2:	0f b7 c0             	movzwl %ax,%eax
f01004f5:	89 fa                	mov    %edi,%edx
f01004f7:	b2 00                	mov    $0x0,%dl
f01004f9:	83 ca 20             	or     $0x20,%edx
f01004fc:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f0100502:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100506:	eb 8f                	jmp    f0100497 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f0100508:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f010050f:	50 
f0100510:	e9 65 ff ff ff       	jmp    f010047a <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100515:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010051c:	8d 50 01             	lea    0x1(%eax),%edx
f010051f:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100526:	0f b7 c0             	movzwl %ax,%eax
f0100529:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010052f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100533:	e9 5f ff ff ff       	jmp    f0100497 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100538:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010053e:	83 ec 04             	sub    $0x4,%esp
f0100541:	68 00 0f 00 00       	push   $0xf00
f0100546:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054c:	52                   	push   %edx
f010054d:	50                   	push   %eax
f010054e:	e8 59 11 00 00       	call   f01016ac <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100553:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100559:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100565:	83 c4 10             	add    $0x10,%esp
f0100568:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010056d:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100570:	39 d0                	cmp    %edx,%eax
f0100572:	75 f4                	jne    f0100568 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100574:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010057b:	50 
f010057c:	e9 25 ff ff ff       	jmp    f01004a6 <cons_putc+0x128>

f0100581 <serial_intr>:
{
f0100581:	f3 0f 1e fb          	endbr32 
f0100585:	e8 f6 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f010058a:	05 7e 0d 01 00       	add    $0x10d7e,%eax
	if (serial_exists)
f010058f:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100596:	75 01                	jne    f0100599 <serial_intr+0x18>
f0100598:	c3                   	ret    
{
f0100599:	55                   	push   %ebp
f010059a:	89 e5                	mov    %esp,%ebp
f010059c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010059f:	8d 80 c8 ee fe ff    	lea    -0x11138(%eax),%eax
f01005a5:	e8 44 fc ff ff       	call   f01001ee <cons_intr>
}
f01005aa:	c9                   	leave  
f01005ab:	c3                   	ret    

f01005ac <kbd_intr>:
{
f01005ac:	f3 0f 1e fb          	endbr32 
f01005b0:	55                   	push   %ebp
f01005b1:	89 e5                	mov    %esp,%ebp
f01005b3:	83 ec 08             	sub    $0x8,%esp
f01005b6:	e8 c5 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f01005bb:	05 4d 0d 01 00       	add    $0x10d4d,%eax
	cons_intr(kbd_proc_data);
f01005c0:	8d 80 48 ef fe ff    	lea    -0x110b8(%eax),%eax
f01005c6:	e8 23 fc ff ff       	call   f01001ee <cons_intr>
}
f01005cb:	c9                   	leave  
f01005cc:	c3                   	ret    

f01005cd <cons_getc>:
{
f01005cd:	f3 0f 1e fb          	endbr32 
f01005d1:	55                   	push   %ebp
f01005d2:	89 e5                	mov    %esp,%ebp
f01005d4:	53                   	push   %ebx
f01005d5:	83 ec 04             	sub    $0x4,%esp
f01005d8:	e8 ef fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01005dd:	81 c3 2b 0d 01 00    	add    $0x10d2b,%ebx
	serial_intr();
f01005e3:	e8 99 ff ff ff       	call   f0100581 <serial_intr>
	kbd_intr();
f01005e8:	e8 bf ff ff ff       	call   f01005ac <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005ed:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f01005f3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005f8:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f01005fe:	74 1f                	je     f010061f <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f0100600:	8d 48 01             	lea    0x1(%eax),%ecx
f0100603:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f010060a:	00 
			cons.rpos = 0;
f010060b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100611:	b8 00 00 00 00       	mov    $0x0,%eax
f0100616:	0f 44 c8             	cmove  %eax,%ecx
f0100619:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f010061f:	89 d0                	mov    %edx,%eax
f0100621:	83 c4 04             	add    $0x4,%esp
f0100624:	5b                   	pop    %ebx
f0100625:	5d                   	pop    %ebp
f0100626:	c3                   	ret    

f0100627 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100627:	f3 0f 1e fb          	endbr32 
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	57                   	push   %edi
f010062f:	56                   	push   %esi
f0100630:	53                   	push   %ebx
f0100631:	83 ec 1c             	sub    $0x1c,%esp
f0100634:	e8 93 fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100639:	81 c3 cf 0c 01 00    	add    $0x10ccf,%ebx
	was = *cp;
f010063f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100646:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010064d:	5a a5 
	if (*cp != 0xA55A) {
f010064f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100656:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010065a:	0f 84 bc 00 00 00    	je     f010071c <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f0100660:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f0100667:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100671:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f0100677:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067c:	89 fa                	mov    %edi,%edx
f010067e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010067f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ec                   	in     (%dx),%al
f0100685:	0f b6 f0             	movzbl %al,%esi
f0100688:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100690:	89 fa                	mov    %edi,%edx
f0100692:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100699:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f010069f:	0f b6 c0             	movzbl %al,%eax
f01006a2:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f01006a4:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b0:	89 c8                	mov    %ecx,%eax
f01006b2:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006b7:	ee                   	out    %al,(%dx)
f01006b8:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006bd:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c2:	89 fa                	mov    %edi,%edx
f01006c4:	ee                   	out    %al,(%dx)
f01006c5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006d5:	89 c8                	mov    %ecx,%eax
f01006d7:	89 f2                	mov    %esi,%edx
f01006d9:	ee                   	out    %al,(%dx)
f01006da:	b8 03 00 00 00       	mov    $0x3,%eax
f01006df:	89 fa                	mov    %edi,%edx
f01006e1:	ee                   	out    %al,(%dx)
f01006e2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006e7:	89 c8                	mov    %ecx,%eax
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ef:	89 f2                	mov    %esi,%edx
f01006f1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006f7:	ec                   	in     (%dx),%al
f01006f8:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006fa:	3c ff                	cmp    $0xff,%al
f01006fc:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f0100703:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100708:	ec                   	in     (%dx),%al
f0100709:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010070e:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010070f:	80 f9 ff             	cmp    $0xff,%cl
f0100712:	74 25                	je     f0100739 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f0100714:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100717:	5b                   	pop    %ebx
f0100718:	5e                   	pop    %esi
f0100719:	5f                   	pop    %edi
f010071a:	5d                   	pop    %ebp
f010071b:	c3                   	ret    
		*cp = was;
f010071c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100723:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f010072a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072d:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100734:	e9 38 ff ff ff       	jmp    f0100671 <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f0100739:	83 ec 0c             	sub    $0xc,%esp
f010073c:	8d 83 68 08 ff ff    	lea    -0xf798(%ebx),%eax
f0100742:	50                   	push   %eax
f0100743:	e8 45 03 00 00       	call   f0100a8d <cprintf>
f0100748:	83 c4 10             	add    $0x10,%esp
}
f010074b:	eb c7                	jmp    f0100714 <cons_init+0xed>

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	f3 0f 1e fb          	endbr32 
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100757:	8b 45 08             	mov    0x8(%ebp),%eax
f010075a:	e8 1f fc ff ff       	call   f010037e <cons_putc>
}
f010075f:	c9                   	leave  
f0100760:	c3                   	ret    

f0100761 <getchar>:

int
getchar(void)
{
f0100761:	f3 0f 1e fb          	endbr32 
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076b:	e8 5d fe ff ff       	call   f01005cd <cons_getc>
f0100770:	85 c0                	test   %eax,%eax
f0100772:	74 f7                	je     f010076b <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <iscons>:

int
iscons(int fdnum)
{
f0100776:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	c3                   	ret    

f0100780 <__x86.get_pc_thunk.ax>:
f0100780:	8b 04 24             	mov    (%esp),%eax
f0100783:	c3                   	ret    

f0100784 <__x86.get_pc_thunk.si>:
f0100784:	8b 34 24             	mov    (%esp),%esi
f0100787:	c3                   	ret    

f0100788 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100788:	f3 0f 1e fb          	endbr32 
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	56                   	push   %esi
f0100790:	53                   	push   %ebx
f0100791:	e8 36 fa ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100796:	81 c3 72 0b 01 00    	add    $0x10b72,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079c:	83 ec 04             	sub    $0x4,%esp
f010079f:	8d 83 98 0a ff ff    	lea    -0xf568(%ebx),%eax
f01007a5:	50                   	push   %eax
f01007a6:	8d 83 b6 0a ff ff    	lea    -0xf54a(%ebx),%eax
f01007ac:	50                   	push   %eax
f01007ad:	8d b3 bb 0a ff ff    	lea    -0xf545(%ebx),%esi
f01007b3:	56                   	push   %esi
f01007b4:	e8 d4 02 00 00       	call   f0100a8d <cprintf>
f01007b9:	83 c4 0c             	add    $0xc,%esp
f01007bc:	8d 83 24 0b ff ff    	lea    -0xf4dc(%ebx),%eax
f01007c2:	50                   	push   %eax
f01007c3:	8d 83 c4 0a ff ff    	lea    -0xf53c(%ebx),%eax
f01007c9:	50                   	push   %eax
f01007ca:	56                   	push   %esi
f01007cb:	e8 bd 02 00 00       	call   f0100a8d <cprintf>
	return 0;
}
f01007d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007d8:	5b                   	pop    %ebx
f01007d9:	5e                   	pop    %esi
f01007da:	5d                   	pop    %ebp
f01007db:	c3                   	ret    

f01007dc <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007dc:	f3 0f 1e fb          	endbr32 
f01007e0:	55                   	push   %ebp
f01007e1:	89 e5                	mov    %esp,%ebp
f01007e3:	57                   	push   %edi
f01007e4:	56                   	push   %esi
f01007e5:	53                   	push   %ebx
f01007e6:	83 ec 18             	sub    $0x18,%esp
f01007e9:	e8 de f9 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01007ee:	81 c3 1a 0b 01 00    	add    $0x10b1a,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f4:	8d 83 cd 0a ff ff    	lea    -0xf533(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 8d 02 00 00       	call   f0100a8d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100800:	83 c4 08             	add    $0x8,%esp
f0100803:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100809:	8d 83 4c 0b ff ff    	lea    -0xf4b4(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 78 02 00 00       	call   f0100a8d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100815:	83 c4 0c             	add    $0xc,%esp
f0100818:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010081e:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100824:	50                   	push   %eax
f0100825:	57                   	push   %edi
f0100826:	8d 83 74 0b ff ff    	lea    -0xf48c(%ebx),%eax
f010082c:	50                   	push   %eax
f010082d:	e8 5b 02 00 00       	call   f0100a8d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100832:	83 c4 0c             	add    $0xc,%esp
f0100835:	c7 c0 cd 1a 10 f0    	mov    $0xf0101acd,%eax
f010083b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100841:	52                   	push   %edx
f0100842:	50                   	push   %eax
f0100843:	8d 83 98 0b ff ff    	lea    -0xf468(%ebx),%eax
f0100849:	50                   	push   %eax
f010084a:	e8 3e 02 00 00       	call   f0100a8d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084f:	83 c4 0c             	add    $0xc,%esp
f0100852:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100858:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010085e:	52                   	push   %edx
f010085f:	50                   	push   %eax
f0100860:	8d 83 bc 0b ff ff    	lea    -0xf444(%ebx),%eax
f0100866:	50                   	push   %eax
f0100867:	e8 21 02 00 00       	call   f0100a8d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100875:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010087b:	50                   	push   %eax
f010087c:	56                   	push   %esi
f010087d:	8d 83 e0 0b ff ff    	lea    -0xf420(%ebx),%eax
f0100883:	50                   	push   %eax
f0100884:	e8 04 02 00 00       	call   f0100a8d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100889:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088c:	29 fe                	sub    %edi,%esi
f010088e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100894:	c1 fe 0a             	sar    $0xa,%esi
f0100897:	56                   	push   %esi
f0100898:	8d 83 04 0c ff ff    	lea    -0xf3fc(%ebx),%eax
f010089e:	50                   	push   %eax
f010089f:	e8 e9 01 00 00       	call   f0100a8d <cprintf>
	return 0;
}
f01008a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ac:	5b                   	pop    %ebx
f01008ad:	5e                   	pop    %esi
f01008ae:	5f                   	pop    %edi
f01008af:	5d                   	pop    %ebp
f01008b0:	c3                   	ret    

f01008b1 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b1:	f3 0f 1e fb          	endbr32 
	// Your code here.
	return 0;
}
f01008b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ba:	c3                   	ret    

f01008bb <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008bb:	f3 0f 1e fb          	endbr32 
f01008bf:	55                   	push   %ebp
f01008c0:	89 e5                	mov    %esp,%ebp
f01008c2:	57                   	push   %edi
f01008c3:	56                   	push   %esi
f01008c4:	53                   	push   %ebx
f01008c5:	83 ec 68             	sub    $0x68,%esp
f01008c8:	e8 ff f8 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01008cd:	81 c3 3b 0a 01 00    	add    $0x10a3b,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008d3:	8d 83 30 0c ff ff    	lea    -0xf3d0(%ebx),%eax
f01008d9:	50                   	push   %eax
f01008da:	e8 ae 01 00 00       	call   f0100a8d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008df:	8d 83 54 0c ff ff    	lea    -0xf3ac(%ebx),%eax
f01008e5:	89 04 24             	mov    %eax,(%esp)
f01008e8:	e8 a0 01 00 00       	call   f0100a8d <cprintf>
f01008ed:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01008f0:	8d 83 ea 0a ff ff    	lea    -0xf516(%ebx),%eax
f01008f6:	89 45 a0             	mov    %eax,-0x60(%ebp)
f01008f9:	e9 dc 00 00 00       	jmp    f01009da <monitor+0x11f>
f01008fe:	83 ec 08             	sub    $0x8,%esp
f0100901:	0f be c0             	movsbl %al,%eax
f0100904:	50                   	push   %eax
f0100905:	ff 75 a0             	pushl  -0x60(%ebp)
f0100908:	e8 0e 0d 00 00       	call   f010161b <strchr>
f010090d:	83 c4 10             	add    $0x10,%esp
f0100910:	85 c0                	test   %eax,%eax
f0100912:	74 74                	je     f0100988 <monitor+0xcd>
			*buf++ = 0;
f0100914:	c6 06 00             	movb   $0x0,(%esi)
f0100917:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f010091a:	8d 76 01             	lea    0x1(%esi),%esi
f010091d:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100920:	0f b6 06             	movzbl (%esi),%eax
f0100923:	84 c0                	test   %al,%al
f0100925:	75 d7                	jne    f01008fe <monitor+0x43>
	argv[argc] = 0;
f0100927:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f010092e:	00 
	if (argc == 0)
f010092f:	85 ff                	test   %edi,%edi
f0100931:	0f 84 a3 00 00 00    	je     f01009da <monitor+0x11f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100937:	83 ec 08             	sub    $0x8,%esp
f010093a:	8d 83 b6 0a ff ff    	lea    -0xf54a(%ebx),%eax
f0100940:	50                   	push   %eax
f0100941:	ff 75 a8             	pushl  -0x58(%ebp)
f0100944:	e8 6c 0c 00 00       	call   f01015b5 <strcmp>
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	85 c0                	test   %eax,%eax
f010094e:	0f 84 b4 00 00 00    	je     f0100a08 <monitor+0x14d>
f0100954:	83 ec 08             	sub    $0x8,%esp
f0100957:	8d 83 c4 0a ff ff    	lea    -0xf53c(%ebx),%eax
f010095d:	50                   	push   %eax
f010095e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100961:	e8 4f 0c 00 00       	call   f01015b5 <strcmp>
f0100966:	83 c4 10             	add    $0x10,%esp
f0100969:	85 c0                	test   %eax,%eax
f010096b:	0f 84 92 00 00 00    	je     f0100a03 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100971:	83 ec 08             	sub    $0x8,%esp
f0100974:	ff 75 a8             	pushl  -0x58(%ebp)
f0100977:	8d 83 0c 0b ff ff    	lea    -0xf4f4(%ebx),%eax
f010097d:	50                   	push   %eax
f010097e:	e8 0a 01 00 00       	call   f0100a8d <cprintf>
	return 0;
f0100983:	83 c4 10             	add    $0x10,%esp
f0100986:	eb 52                	jmp    f01009da <monitor+0x11f>
		if (*buf == 0)
f0100988:	80 3e 00             	cmpb   $0x0,(%esi)
f010098b:	74 9a                	je     f0100927 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f010098d:	83 ff 0f             	cmp    $0xf,%edi
f0100990:	74 34                	je     f01009c6 <monitor+0x10b>
		argv[argc++] = buf;
f0100992:	8d 47 01             	lea    0x1(%edi),%eax
f0100995:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100998:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f010099c:	0f b6 06             	movzbl (%esi),%eax
f010099f:	84 c0                	test   %al,%al
f01009a1:	0f 84 76 ff ff ff    	je     f010091d <monitor+0x62>
f01009a7:	83 ec 08             	sub    $0x8,%esp
f01009aa:	0f be c0             	movsbl %al,%eax
f01009ad:	50                   	push   %eax
f01009ae:	ff 75 a0             	pushl  -0x60(%ebp)
f01009b1:	e8 65 0c 00 00       	call   f010161b <strchr>
f01009b6:	83 c4 10             	add    $0x10,%esp
f01009b9:	85 c0                	test   %eax,%eax
f01009bb:	0f 85 5c ff ff ff    	jne    f010091d <monitor+0x62>
			buf++;
f01009c1:	83 c6 01             	add    $0x1,%esi
f01009c4:	eb d6                	jmp    f010099c <monitor+0xe1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009c6:	83 ec 08             	sub    $0x8,%esp
f01009c9:	6a 10                	push   $0x10
f01009cb:	8d 83 ef 0a ff ff    	lea    -0xf511(%ebx),%eax
f01009d1:	50                   	push   %eax
f01009d2:	e8 b6 00 00 00       	call   f0100a8d <cprintf>
			return 0;
f01009d7:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009da:	8d bb e6 0a ff ff    	lea    -0xf51a(%ebx),%edi
f01009e0:	83 ec 0c             	sub    $0xc,%esp
f01009e3:	57                   	push   %edi
f01009e4:	e8 c1 09 00 00       	call   f01013aa <readline>
f01009e9:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009eb:	83 c4 10             	add    $0x10,%esp
f01009ee:	85 c0                	test   %eax,%eax
f01009f0:	74 ee                	je     f01009e0 <monitor+0x125>
	argv[argc] = 0;
f01009f2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009f9:	bf 00 00 00 00       	mov    $0x0,%edi
f01009fe:	e9 1d ff ff ff       	jmp    f0100920 <monitor+0x65>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a03:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a08:	83 ec 04             	sub    $0x4,%esp
f0100a0b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a0e:	ff 75 08             	pushl  0x8(%ebp)
f0100a11:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a14:	52                   	push   %edx
f0100a15:	57                   	push   %edi
f0100a16:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a1d:	83 c4 10             	add    $0x10,%esp
f0100a20:	85 c0                	test   %eax,%eax
f0100a22:	79 b6                	jns    f01009da <monitor+0x11f>
				break;
	}
}
f0100a24:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a27:	5b                   	pop    %ebx
f0100a28:	5e                   	pop    %esi
f0100a29:	5f                   	pop    %edi
f0100a2a:	5d                   	pop    %ebp
f0100a2b:	c3                   	ret    

f0100a2c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a2c:	f3 0f 1e fb          	endbr32 
f0100a30:	55                   	push   %ebp
f0100a31:	89 e5                	mov    %esp,%ebp
f0100a33:	53                   	push   %ebx
f0100a34:	83 ec 10             	sub    $0x10,%esp
f0100a37:	e8 90 f7 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100a3c:	81 c3 cc 08 01 00    	add    $0x108cc,%ebx
	cputchar(ch);
f0100a42:	ff 75 08             	pushl  0x8(%ebp)
f0100a45:	e8 03 fd ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0100a4a:	83 c4 10             	add    $0x10,%esp
f0100a4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a50:	c9                   	leave  
f0100a51:	c3                   	ret    

f0100a52 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a52:	f3 0f 1e fb          	endbr32 
f0100a56:	55                   	push   %ebp
f0100a57:	89 e5                	mov    %esp,%ebp
f0100a59:	53                   	push   %ebx
f0100a5a:	83 ec 14             	sub    $0x14,%esp
f0100a5d:	e8 6a f7 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100a62:	81 c3 a6 08 01 00    	add    $0x108a6,%ebx
	int cnt = 0;
f0100a68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a6f:	ff 75 0c             	pushl  0xc(%ebp)
f0100a72:	ff 75 08             	pushl  0x8(%ebp)
f0100a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a78:	50                   	push   %eax
f0100a79:	8d 83 24 f7 fe ff    	lea    -0x108dc(%ebx),%eax
f0100a7f:	50                   	push   %eax
f0100a80:	e8 27 04 00 00       	call   f0100eac <vprintfmt>
	return cnt;
}
f0100a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a8b:	c9                   	leave  
f0100a8c:	c3                   	ret    

f0100a8d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a8d:	f3 0f 1e fb          	endbr32 
f0100a91:	55                   	push   %ebp
f0100a92:	89 e5                	mov    %esp,%ebp
f0100a94:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a97:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a9a:	50                   	push   %eax
f0100a9b:	ff 75 08             	pushl  0x8(%ebp)
f0100a9e:	e8 af ff ff ff       	call   f0100a52 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100aa3:	c9                   	leave  
f0100aa4:	c3                   	ret    

f0100aa5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100aa5:	55                   	push   %ebp
f0100aa6:	89 e5                	mov    %esp,%ebp
f0100aa8:	57                   	push   %edi
f0100aa9:	56                   	push   %esi
f0100aaa:	53                   	push   %ebx
f0100aab:	83 ec 14             	sub    $0x14,%esp
f0100aae:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100ab1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100ab4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100ab7:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100aba:	8b 1a                	mov    (%edx),%ebx
f0100abc:	8b 01                	mov    (%ecx),%eax
f0100abe:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ac1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100ac8:	eb 23                	jmp    f0100aed <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100aca:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100acd:	eb 1e                	jmp    f0100aed <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100acf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ad2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ad5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100ad9:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100adc:	73 46                	jae    f0100b24 <stab_binsearch+0x7f>
			*region_left = m;
f0100ade:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ae1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100ae3:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100ae6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100aed:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100af0:	7f 5f                	jg     f0100b51 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100af5:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100af8:	89 d0                	mov    %edx,%eax
f0100afa:	c1 e8 1f             	shr    $0x1f,%eax
f0100afd:	01 d0                	add    %edx,%eax
f0100aff:	89 c7                	mov    %eax,%edi
f0100b01:	d1 ff                	sar    %edi
f0100b03:	83 e0 fe             	and    $0xfffffffe,%eax
f0100b06:	01 f8                	add    %edi,%eax
f0100b08:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b0b:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b0f:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b11:	39 c3                	cmp    %eax,%ebx
f0100b13:	7f b5                	jg     f0100aca <stab_binsearch+0x25>
f0100b15:	0f b6 0a             	movzbl (%edx),%ecx
f0100b18:	83 ea 0c             	sub    $0xc,%edx
f0100b1b:	39 f1                	cmp    %esi,%ecx
f0100b1d:	74 b0                	je     f0100acf <stab_binsearch+0x2a>
			m--;
f0100b1f:	83 e8 01             	sub    $0x1,%eax
f0100b22:	eb ed                	jmp    f0100b11 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100b24:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b27:	76 14                	jbe    f0100b3d <stab_binsearch+0x98>
			*region_right = m - 1;
f0100b29:	83 e8 01             	sub    $0x1,%eax
f0100b2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b2f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b32:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100b34:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b3b:	eb b0                	jmp    f0100aed <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b40:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100b42:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b46:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100b48:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b4f:	eb 9c                	jmp    f0100aed <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100b51:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b55:	75 15                	jne    f0100b6c <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100b57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b5a:	8b 00                	mov    (%eax),%eax
f0100b5c:	83 e8 01             	sub    $0x1,%eax
f0100b5f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b62:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100b64:	83 c4 14             	add    $0x14,%esp
f0100b67:	5b                   	pop    %ebx
f0100b68:	5e                   	pop    %esi
f0100b69:	5f                   	pop    %edi
f0100b6a:	5d                   	pop    %ebp
f0100b6b:	c3                   	ret    
		for (l = *region_right;
f0100b6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b6f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b74:	8b 0f                	mov    (%edi),%ecx
f0100b76:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b79:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100b7c:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100b80:	eb 03                	jmp    f0100b85 <stab_binsearch+0xe0>
		     l--)
f0100b82:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100b85:	39 c1                	cmp    %eax,%ecx
f0100b87:	7d 0a                	jge    f0100b93 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100b89:	0f b6 1a             	movzbl (%edx),%ebx
f0100b8c:	83 ea 0c             	sub    $0xc,%edx
f0100b8f:	39 f3                	cmp    %esi,%ebx
f0100b91:	75 ef                	jne    f0100b82 <stab_binsearch+0xdd>
		*region_left = l;
f0100b93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b96:	89 07                	mov    %eax,(%edi)
}
f0100b98:	eb ca                	jmp    f0100b64 <stab_binsearch+0xbf>

f0100b9a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b9a:	f3 0f 1e fb          	endbr32 
f0100b9e:	55                   	push   %ebp
f0100b9f:	89 e5                	mov    %esp,%ebp
f0100ba1:	57                   	push   %edi
f0100ba2:	56                   	push   %esi
f0100ba3:	53                   	push   %ebx
f0100ba4:	83 ec 2c             	sub    $0x2c,%esp
f0100ba7:	e8 fc 01 00 00       	call   f0100da8 <__x86.get_pc_thunk.cx>
f0100bac:	81 c1 5c 07 01 00    	add    $0x1075c,%ecx
f0100bb2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100bb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100bb8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100bbb:	8d 81 79 0c ff ff    	lea    -0xf387(%ecx),%eax
f0100bc1:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100bc3:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100bca:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100bcd:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100bd4:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0100bd7:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100bde:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100be4:	0f 86 f4 00 00 00    	jbe    f0100cde <debuginfo_eip+0x144>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100bea:	c7 c0 2d 64 10 f0    	mov    $0xf010642d,%eax
f0100bf0:	39 81 fc ff ff ff    	cmp    %eax,-0x4(%ecx)
f0100bf6:	0f 86 88 01 00 00    	jbe    f0100d84 <debuginfo_eip+0x1ea>
f0100bfc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100bff:	c7 c0 ab 7d 10 f0    	mov    $0xf0107dab,%eax
f0100c05:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c09:	0f 85 7c 01 00 00    	jne    f0100d8b <debuginfo_eip+0x1f1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c0f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c16:	c7 c0 9c 21 10 f0    	mov    $0xf010219c,%eax
f0100c1c:	c7 c2 2c 64 10 f0    	mov    $0xf010642c,%edx
f0100c22:	29 c2                	sub    %eax,%edx
f0100c24:	c1 fa 02             	sar    $0x2,%edx
f0100c27:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c2d:	83 ea 01             	sub    $0x1,%edx
f0100c30:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c33:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c36:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c39:	83 ec 08             	sub    $0x8,%esp
f0100c3c:	53                   	push   %ebx
f0100c3d:	6a 64                	push   $0x64
f0100c3f:	e8 61 fe ff ff       	call   f0100aa5 <stab_binsearch>
	if (lfile == 0)
f0100c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c47:	83 c4 10             	add    $0x10,%esp
f0100c4a:	85 c0                	test   %eax,%eax
f0100c4c:	0f 84 40 01 00 00    	je     f0100d92 <debuginfo_eip+0x1f8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c52:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c55:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c5b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c5e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c61:	83 ec 08             	sub    $0x8,%esp
f0100c64:	53                   	push   %ebx
f0100c65:	6a 24                	push   $0x24
f0100c67:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100c6a:	c7 c0 9c 21 10 f0    	mov    $0xf010219c,%eax
f0100c70:	e8 30 fe ff ff       	call   f0100aa5 <stab_binsearch>

	if (lfun <= rfun) {
f0100c75:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100c78:	83 c4 10             	add    $0x10,%esp
f0100c7b:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f0100c7e:	7f 79                	jg     f0100cf9 <debuginfo_eip+0x15f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c80:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c83:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c86:	c7 c2 9c 21 10 f0    	mov    $0xf010219c,%edx
f0100c8c:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100c8f:	8b 11                	mov    (%ecx),%edx
f0100c91:	c7 c0 ab 7d 10 f0    	mov    $0xf0107dab,%eax
f0100c97:	81 e8 2d 64 10 f0    	sub    $0xf010642d,%eax
f0100c9d:	39 c2                	cmp    %eax,%edx
f0100c9f:	73 09                	jae    f0100caa <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100ca1:	81 c2 2d 64 10 f0    	add    $0xf010642d,%edx
f0100ca7:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100caa:	8b 41 08             	mov    0x8(%ecx),%eax
f0100cad:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100cb0:	83 ec 08             	sub    $0x8,%esp
f0100cb3:	6a 3a                	push   $0x3a
f0100cb5:	ff 77 08             	pushl  0x8(%edi)
f0100cb8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cbb:	e8 80 09 00 00       	call   f0101640 <strfind>
f0100cc0:	2b 47 08             	sub    0x8(%edi),%eax
f0100cc3:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100cc6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100cc9:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100ccc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100ccf:	c7 c2 9c 21 10 f0    	mov    $0xf010219c,%edx
f0100cd5:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0100cd9:	83 c4 10             	add    $0x10,%esp
f0100cdc:	eb 29                	jmp    f0100d07 <debuginfo_eip+0x16d>
  	        panic("User address");
f0100cde:	83 ec 04             	sub    $0x4,%esp
f0100ce1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ce4:	8d 83 83 0c ff ff    	lea    -0xf37d(%ebx),%eax
f0100cea:	50                   	push   %eax
f0100ceb:	6a 7f                	push   $0x7f
f0100ced:	8d 83 90 0c ff ff    	lea    -0xf370(%ebx),%eax
f0100cf3:	50                   	push   %eax
f0100cf4:	e8 15 f4 ff ff       	call   f010010e <_panic>
		info->eip_fn_addr = addr;
f0100cf9:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0100cfc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100cff:	eb af                	jmp    f0100cb0 <debuginfo_eip+0x116>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100d01:	83 ee 01             	sub    $0x1,%esi
f0100d04:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100d07:	39 f3                	cmp    %esi,%ebx
f0100d09:	7f 3a                	jg     f0100d45 <debuginfo_eip+0x1ab>
	       && stabs[lline].n_type != N_SOL
f0100d0b:	0f b6 10             	movzbl (%eax),%edx
f0100d0e:	80 fa 84             	cmp    $0x84,%dl
f0100d11:	74 0b                	je     f0100d1e <debuginfo_eip+0x184>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d13:	80 fa 64             	cmp    $0x64,%dl
f0100d16:	75 e9                	jne    f0100d01 <debuginfo_eip+0x167>
f0100d18:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100d1c:	74 e3                	je     f0100d01 <debuginfo_eip+0x167>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d1e:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100d21:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d24:	c7 c0 9c 21 10 f0    	mov    $0xf010219c,%eax
f0100d2a:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100d2d:	c7 c0 ab 7d 10 f0    	mov    $0xf0107dab,%eax
f0100d33:	81 e8 2d 64 10 f0    	sub    $0xf010642d,%eax
f0100d39:	39 c2                	cmp    %eax,%edx
f0100d3b:	73 08                	jae    f0100d45 <debuginfo_eip+0x1ab>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100d3d:	81 c2 2d 64 10 f0    	add    $0xf010642d,%edx
f0100d43:	89 17                	mov    %edx,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100d45:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d48:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d4b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0100d50:	39 c8                	cmp    %ecx,%eax
f0100d52:	7d 4a                	jge    f0100d9e <debuginfo_eip+0x204>
		for (lline = lfun + 1;
f0100d54:	8d 50 01             	lea    0x1(%eax),%edx
f0100d57:	8d 1c 40             	lea    (%eax,%eax,2),%ebx
f0100d5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d5d:	c7 c0 9c 21 10 f0    	mov    $0xf010219c,%eax
f0100d63:	8d 44 98 10          	lea    0x10(%eax,%ebx,4),%eax
f0100d67:	eb 07                	jmp    f0100d70 <debuginfo_eip+0x1d6>
			info->eip_fn_narg++;
f0100d69:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100d6d:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0100d70:	39 d1                	cmp    %edx,%ecx
f0100d72:	74 25                	je     f0100d99 <debuginfo_eip+0x1ff>
f0100d74:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d77:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100d7b:	74 ec                	je     f0100d69 <debuginfo_eip+0x1cf>
	return 0;
f0100d7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d82:	eb 1a                	jmp    f0100d9e <debuginfo_eip+0x204>
		return -1;
f0100d84:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d89:	eb 13                	jmp    f0100d9e <debuginfo_eip+0x204>
f0100d8b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d90:	eb 0c                	jmp    f0100d9e <debuginfo_eip+0x204>
		return -1;
f0100d92:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d97:	eb 05                	jmp    f0100d9e <debuginfo_eip+0x204>
	return 0;
f0100d99:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d9e:	89 d0                	mov    %edx,%eax
f0100da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100da3:	5b                   	pop    %ebx
f0100da4:	5e                   	pop    %esi
f0100da5:	5f                   	pop    %edi
f0100da6:	5d                   	pop    %ebp
f0100da7:	c3                   	ret    

f0100da8 <__x86.get_pc_thunk.cx>:
f0100da8:	8b 0c 24             	mov    (%esp),%ecx
f0100dab:	c3                   	ret    

f0100dac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100dac:	55                   	push   %ebp
f0100dad:	89 e5                	mov    %esp,%ebp
f0100daf:	57                   	push   %edi
f0100db0:	56                   	push   %esi
f0100db1:	53                   	push   %ebx
f0100db2:	83 ec 2c             	sub    $0x2c,%esp
f0100db5:	e8 ee ff ff ff       	call   f0100da8 <__x86.get_pc_thunk.cx>
f0100dba:	81 c1 4e 05 01 00    	add    $0x1054e,%ecx
f0100dc0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100dc3:	89 c7                	mov    %eax,%edi
f0100dc5:	89 d6                	mov    %edx,%esi
f0100dc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dca:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100dcd:	89 d1                	mov    %edx,%ecx
f0100dcf:	89 c2                	mov    %eax,%edx
f0100dd1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dd4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100dd7:	8b 45 10             	mov    0x10(%ebp),%eax
f0100dda:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ddd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100de0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100de7:	39 c2                	cmp    %eax,%edx
f0100de9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100dec:	72 41                	jb     f0100e2f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100dee:	83 ec 0c             	sub    $0xc,%esp
f0100df1:	ff 75 18             	pushl  0x18(%ebp)
f0100df4:	83 eb 01             	sub    $0x1,%ebx
f0100df7:	53                   	push   %ebx
f0100df8:	50                   	push   %eax
f0100df9:	83 ec 08             	sub    $0x8,%esp
f0100dfc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100dff:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e02:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100e05:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e08:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e0b:	e8 60 0a 00 00       	call   f0101870 <__udivdi3>
f0100e10:	83 c4 18             	add    $0x18,%esp
f0100e13:	52                   	push   %edx
f0100e14:	50                   	push   %eax
f0100e15:	89 f2                	mov    %esi,%edx
f0100e17:	89 f8                	mov    %edi,%eax
f0100e19:	e8 8e ff ff ff       	call   f0100dac <printnum>
f0100e1e:	83 c4 20             	add    $0x20,%esp
f0100e21:	eb 13                	jmp    f0100e36 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e23:	83 ec 08             	sub    $0x8,%esp
f0100e26:	56                   	push   %esi
f0100e27:	ff 75 18             	pushl  0x18(%ebp)
f0100e2a:	ff d7                	call   *%edi
f0100e2c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100e2f:	83 eb 01             	sub    $0x1,%ebx
f0100e32:	85 db                	test   %ebx,%ebx
f0100e34:	7f ed                	jg     f0100e23 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100e36:	83 ec 08             	sub    $0x8,%esp
f0100e39:	56                   	push   %esi
f0100e3a:	83 ec 04             	sub    $0x4,%esp
f0100e3d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e40:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e43:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100e46:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e49:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e4c:	e8 2f 0b 00 00       	call   f0101980 <__umoddi3>
f0100e51:	83 c4 14             	add    $0x14,%esp
f0100e54:	0f be 84 03 9e 0c ff 	movsbl -0xf362(%ebx,%eax,1),%eax
f0100e5b:	ff 
f0100e5c:	50                   	push   %eax
f0100e5d:	ff d7                	call   *%edi
}
f0100e5f:	83 c4 10             	add    $0x10,%esp
f0100e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e65:	5b                   	pop    %ebx
f0100e66:	5e                   	pop    %esi
f0100e67:	5f                   	pop    %edi
f0100e68:	5d                   	pop    %ebp
f0100e69:	c3                   	ret    

f0100e6a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e6a:	f3 0f 1e fb          	endbr32 
f0100e6e:	55                   	push   %ebp
f0100e6f:	89 e5                	mov    %esp,%ebp
f0100e71:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e74:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e78:	8b 10                	mov    (%eax),%edx
f0100e7a:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e7d:	73 0a                	jae    f0100e89 <sprintputch+0x1f>
		*b->buf++ = ch;
f0100e7f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e82:	89 08                	mov    %ecx,(%eax)
f0100e84:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e87:	88 02                	mov    %al,(%edx)
}
f0100e89:	5d                   	pop    %ebp
f0100e8a:	c3                   	ret    

f0100e8b <printfmt>:
{
f0100e8b:	f3 0f 1e fb          	endbr32 
f0100e8f:	55                   	push   %ebp
f0100e90:	89 e5                	mov    %esp,%ebp
f0100e92:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100e95:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e98:	50                   	push   %eax
f0100e99:	ff 75 10             	pushl  0x10(%ebp)
f0100e9c:	ff 75 0c             	pushl  0xc(%ebp)
f0100e9f:	ff 75 08             	pushl  0x8(%ebp)
f0100ea2:	e8 05 00 00 00       	call   f0100eac <vprintfmt>
}
f0100ea7:	83 c4 10             	add    $0x10,%esp
f0100eaa:	c9                   	leave  
f0100eab:	c3                   	ret    

f0100eac <vprintfmt>:
{
f0100eac:	f3 0f 1e fb          	endbr32 
f0100eb0:	55                   	push   %ebp
f0100eb1:	89 e5                	mov    %esp,%ebp
f0100eb3:	57                   	push   %edi
f0100eb4:	56                   	push   %esi
f0100eb5:	53                   	push   %ebx
f0100eb6:	83 ec 3c             	sub    $0x3c,%esp
f0100eb9:	e8 c2 f8 ff ff       	call   f0100780 <__x86.get_pc_thunk.ax>
f0100ebe:	05 4a 04 01 00       	add    $0x1044a,%eax
f0100ec3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ec6:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ec9:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ecf:	8d 80 20 1d 00 00    	lea    0x1d20(%eax),%eax
f0100ed5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100ed8:	e9 95 03 00 00       	jmp    f0101272 <.L25+0x48>
		padc = ' ';
f0100edd:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100ee1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0100ee8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100eef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0100ef6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100efb:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100efe:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f01:	8d 43 01             	lea    0x1(%ebx),%eax
f0100f04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f07:	0f b6 13             	movzbl (%ebx),%edx
f0100f0a:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100f0d:	3c 55                	cmp    $0x55,%al
f0100f0f:	0f 87 e9 03 00 00    	ja     f01012fe <.L20>
f0100f15:	0f b6 c0             	movzbl %al,%eax
f0100f18:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f1b:	89 ce                	mov    %ecx,%esi
f0100f1d:	03 b4 81 2c 0d ff ff 	add    -0xf2d4(%ecx,%eax,4),%esi
f0100f24:	3e ff e6             	notrack jmp *%esi

f0100f27 <.L66>:
f0100f27:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0100f2a:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100f2e:	eb d1                	jmp    f0100f01 <vprintfmt+0x55>

f0100f30 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100f30:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f33:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100f37:	eb c8                	jmp    f0100f01 <vprintfmt+0x55>

f0100f39 <.L31>:
f0100f39:	0f b6 d2             	movzbl %dl,%edx
f0100f3c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0100f3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f44:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0100f47:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100f4a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100f4e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0100f51:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100f54:	83 f9 09             	cmp    $0x9,%ecx
f0100f57:	77 58                	ja     f0100fb1 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0100f59:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0100f5c:	eb e9                	jmp    f0100f47 <.L31+0xe>

f0100f5e <.L34>:
			precision = va_arg(ap, int);
f0100f5e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f61:	8b 00                	mov    (%eax),%eax
f0100f63:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f66:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f69:	8d 40 04             	lea    0x4(%eax),%eax
f0100f6c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f6f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0100f72:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100f76:	79 89                	jns    f0100f01 <vprintfmt+0x55>
				width = precision, precision = -1;
f0100f78:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f7e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0100f85:	e9 77 ff ff ff       	jmp    f0100f01 <vprintfmt+0x55>

f0100f8a <.L33>:
f0100f8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f8d:	85 c0                	test   %eax,%eax
f0100f8f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f94:	0f 49 d0             	cmovns %eax,%edx
f0100f97:	89 55 d0             	mov    %edx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f9a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0100f9d:	e9 5f ff ff ff       	jmp    f0100f01 <vprintfmt+0x55>

f0100fa2 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0100fa2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0100fa5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0100fac:	e9 50 ff ff ff       	jmp    f0100f01 <vprintfmt+0x55>
f0100fb1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fb4:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fb7:	eb b9                	jmp    f0100f72 <.L34+0x14>

f0100fb9 <.L27>:
			lflag++;
f0100fb9:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fbd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0100fc0:	e9 3c ff ff ff       	jmp    f0100f01 <vprintfmt+0x55>

f0100fc5 <.L30>:
f0100fc5:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0100fc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fcb:	8d 58 04             	lea    0x4(%eax),%ebx
f0100fce:	83 ec 08             	sub    $0x8,%esp
f0100fd1:	57                   	push   %edi
f0100fd2:	ff 30                	pushl  (%eax)
f0100fd4:	ff d6                	call   *%esi
			break;
f0100fd6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100fd9:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0100fdc:	e9 8e 02 00 00       	jmp    f010126f <.L25+0x45>

f0100fe1 <.L28>:
f0100fe1:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f0100fe4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fe7:	8d 58 04             	lea    0x4(%eax),%ebx
f0100fea:	8b 00                	mov    (%eax),%eax
f0100fec:	99                   	cltd   
f0100fed:	31 d0                	xor    %edx,%eax
f0100fef:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ff1:	83 f8 06             	cmp    $0x6,%eax
f0100ff4:	7f 27                	jg     f010101d <.L28+0x3c>
f0100ff6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100ff9:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0100ffc:	85 d2                	test   %edx,%edx
f0100ffe:	74 1d                	je     f010101d <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f0101000:	52                   	push   %edx
f0101001:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101004:	8d 80 bf 0c ff ff    	lea    -0xf341(%eax),%eax
f010100a:	50                   	push   %eax
f010100b:	57                   	push   %edi
f010100c:	56                   	push   %esi
f010100d:	e8 79 fe ff ff       	call   f0100e8b <printfmt>
f0101012:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101015:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101018:	e9 52 02 00 00       	jmp    f010126f <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010101d:	50                   	push   %eax
f010101e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101021:	8d 80 b6 0c ff ff    	lea    -0xf34a(%eax),%eax
f0101027:	50                   	push   %eax
f0101028:	57                   	push   %edi
f0101029:	56                   	push   %esi
f010102a:	e8 5c fe ff ff       	call   f0100e8b <printfmt>
f010102f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101032:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101035:	e9 35 02 00 00       	jmp    f010126f <.L25+0x45>

f010103a <.L24>:
f010103a:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f010103d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101040:	83 c0 04             	add    $0x4,%eax
f0101043:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0101046:	8b 45 14             	mov    0x14(%ebp),%eax
f0101049:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010104b:	85 d2                	test   %edx,%edx
f010104d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101050:	8d 80 af 0c ff ff    	lea    -0xf351(%eax),%eax
f0101056:	0f 45 c2             	cmovne %edx,%eax
f0101059:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f010105c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101060:	7e 06                	jle    f0101068 <.L24+0x2e>
f0101062:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101066:	75 0d                	jne    f0101075 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101068:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010106b:	89 c3                	mov    %eax,%ebx
f010106d:	03 45 d0             	add    -0x30(%ebp),%eax
f0101070:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101073:	eb 58                	jmp    f01010cd <.L24+0x93>
f0101075:	83 ec 08             	sub    $0x8,%esp
f0101078:	ff 75 d8             	pushl  -0x28(%ebp)
f010107b:	ff 75 c8             	pushl  -0x38(%ebp)
f010107e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101081:	e8 49 04 00 00       	call   f01014cf <strnlen>
f0101086:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101089:	29 c2                	sub    %eax,%edx
f010108b:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010108e:	83 c4 10             	add    $0x10,%esp
f0101091:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0101093:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101097:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010109a:	85 db                	test   %ebx,%ebx
f010109c:	7e 11                	jle    f01010af <.L24+0x75>
					putch(padc, putdat);
f010109e:	83 ec 08             	sub    $0x8,%esp
f01010a1:	57                   	push   %edi
f01010a2:	ff 75 d0             	pushl  -0x30(%ebp)
f01010a5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01010a7:	83 eb 01             	sub    $0x1,%ebx
f01010aa:	83 c4 10             	add    $0x10,%esp
f01010ad:	eb eb                	jmp    f010109a <.L24+0x60>
f01010af:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01010b2:	85 d2                	test   %edx,%edx
f01010b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01010b9:	0f 49 c2             	cmovns %edx,%eax
f01010bc:	29 c2                	sub    %eax,%edx
f01010be:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01010c1:	eb a5                	jmp    f0101068 <.L24+0x2e>
					putch(ch, putdat);
f01010c3:	83 ec 08             	sub    $0x8,%esp
f01010c6:	57                   	push   %edi
f01010c7:	52                   	push   %edx
f01010c8:	ff d6                	call   *%esi
f01010ca:	83 c4 10             	add    $0x10,%esp
f01010cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01010d0:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01010d2:	83 c3 01             	add    $0x1,%ebx
f01010d5:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01010d9:	0f be d0             	movsbl %al,%edx
f01010dc:	85 d2                	test   %edx,%edx
f01010de:	74 4b                	je     f010112b <.L24+0xf1>
f01010e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01010e4:	78 06                	js     f01010ec <.L24+0xb2>
f01010e6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01010ea:	78 1e                	js     f010110a <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f01010ec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01010f0:	74 d1                	je     f01010c3 <.L24+0x89>
f01010f2:	0f be c0             	movsbl %al,%eax
f01010f5:	83 e8 20             	sub    $0x20,%eax
f01010f8:	83 f8 5e             	cmp    $0x5e,%eax
f01010fb:	76 c6                	jbe    f01010c3 <.L24+0x89>
					putch('?', putdat);
f01010fd:	83 ec 08             	sub    $0x8,%esp
f0101100:	57                   	push   %edi
f0101101:	6a 3f                	push   $0x3f
f0101103:	ff d6                	call   *%esi
f0101105:	83 c4 10             	add    $0x10,%esp
f0101108:	eb c3                	jmp    f01010cd <.L24+0x93>
f010110a:	89 cb                	mov    %ecx,%ebx
f010110c:	eb 0e                	jmp    f010111c <.L24+0xe2>
				putch(' ', putdat);
f010110e:	83 ec 08             	sub    $0x8,%esp
f0101111:	57                   	push   %edi
f0101112:	6a 20                	push   $0x20
f0101114:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101116:	83 eb 01             	sub    $0x1,%ebx
f0101119:	83 c4 10             	add    $0x10,%esp
f010111c:	85 db                	test   %ebx,%ebx
f010111e:	7f ee                	jg     f010110e <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0101120:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0101123:	89 45 14             	mov    %eax,0x14(%ebp)
f0101126:	e9 44 01 00 00       	jmp    f010126f <.L25+0x45>
f010112b:	89 cb                	mov    %ecx,%ebx
f010112d:	eb ed                	jmp    f010111c <.L24+0xe2>

f010112f <.L29>:
f010112f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101132:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101135:	83 f9 01             	cmp    $0x1,%ecx
f0101138:	7f 1b                	jg     f0101155 <.L29+0x26>
	else if (lflag)
f010113a:	85 c9                	test   %ecx,%ecx
f010113c:	74 63                	je     f01011a1 <.L29+0x72>
		return va_arg(*ap, long);
f010113e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101141:	8b 00                	mov    (%eax),%eax
f0101143:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101146:	99                   	cltd   
f0101147:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010114a:	8b 45 14             	mov    0x14(%ebp),%eax
f010114d:	8d 40 04             	lea    0x4(%eax),%eax
f0101150:	89 45 14             	mov    %eax,0x14(%ebp)
f0101153:	eb 17                	jmp    f010116c <.L29+0x3d>
		return va_arg(*ap, long long);
f0101155:	8b 45 14             	mov    0x14(%ebp),%eax
f0101158:	8b 50 04             	mov    0x4(%eax),%edx
f010115b:	8b 00                	mov    (%eax),%eax
f010115d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101160:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101163:	8b 45 14             	mov    0x14(%ebp),%eax
f0101166:	8d 40 08             	lea    0x8(%eax),%eax
f0101169:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010116c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010116f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101172:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0101177:	85 c9                	test   %ecx,%ecx
f0101179:	0f 89 d6 00 00 00    	jns    f0101255 <.L25+0x2b>
				putch('-', putdat);
f010117f:	83 ec 08             	sub    $0x8,%esp
f0101182:	57                   	push   %edi
f0101183:	6a 2d                	push   $0x2d
f0101185:	ff d6                	call   *%esi
				num = -(long long) num;
f0101187:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010118a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010118d:	f7 da                	neg    %edx
f010118f:	83 d1 00             	adc    $0x0,%ecx
f0101192:	f7 d9                	neg    %ecx
f0101194:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101197:	b8 0a 00 00 00       	mov    $0xa,%eax
f010119c:	e9 b4 00 00 00       	jmp    f0101255 <.L25+0x2b>
		return va_arg(*ap, int);
f01011a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01011a4:	8b 00                	mov    (%eax),%eax
f01011a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011a9:	99                   	cltd   
f01011aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01011b0:	8d 40 04             	lea    0x4(%eax),%eax
f01011b3:	89 45 14             	mov    %eax,0x14(%ebp)
f01011b6:	eb b4                	jmp    f010116c <.L29+0x3d>

f01011b8 <.L23>:
f01011b8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01011bb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01011be:	83 f9 01             	cmp    $0x1,%ecx
f01011c1:	7f 1b                	jg     f01011de <.L23+0x26>
	else if (lflag)
f01011c3:	85 c9                	test   %ecx,%ecx
f01011c5:	74 2c                	je     f01011f3 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f01011c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ca:	8b 10                	mov    (%eax),%edx
f01011cc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011d1:	8d 40 04             	lea    0x4(%eax),%eax
f01011d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01011d7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01011dc:	eb 77                	jmp    f0101255 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01011de:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e1:	8b 10                	mov    (%eax),%edx
f01011e3:	8b 48 04             	mov    0x4(%eax),%ecx
f01011e6:	8d 40 08             	lea    0x8(%eax),%eax
f01011e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01011ec:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01011f1:	eb 62                	jmp    f0101255 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01011f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01011f6:	8b 10                	mov    (%eax),%edx
f01011f8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011fd:	8d 40 04             	lea    0x4(%eax),%eax
f0101200:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101203:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0101208:	eb 4b                	jmp    f0101255 <.L25+0x2b>

f010120a <.L26>:
f010120a:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('X', putdat);
f010120d:	83 ec 08             	sub    $0x8,%esp
f0101210:	57                   	push   %edi
f0101211:	6a 58                	push   $0x58
f0101213:	ff d6                	call   *%esi
			putch('X', putdat);
f0101215:	83 c4 08             	add    $0x8,%esp
f0101218:	57                   	push   %edi
f0101219:	6a 58                	push   $0x58
f010121b:	ff d6                	call   *%esi
			putch('X', putdat);
f010121d:	83 c4 08             	add    $0x8,%esp
f0101220:	57                   	push   %edi
f0101221:	6a 58                	push   $0x58
f0101223:	ff d6                	call   *%esi
			break;
f0101225:	83 c4 10             	add    $0x10,%esp
f0101228:	eb 45                	jmp    f010126f <.L25+0x45>

f010122a <.L25>:
f010122a:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f010122d:	83 ec 08             	sub    $0x8,%esp
f0101230:	57                   	push   %edi
f0101231:	6a 30                	push   $0x30
f0101233:	ff d6                	call   *%esi
			putch('x', putdat);
f0101235:	83 c4 08             	add    $0x8,%esp
f0101238:	57                   	push   %edi
f0101239:	6a 78                	push   $0x78
f010123b:	ff d6                	call   *%esi
			num = (unsigned long long)
f010123d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101240:	8b 10                	mov    (%eax),%edx
f0101242:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101247:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010124a:	8d 40 04             	lea    0x4(%eax),%eax
f010124d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101250:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101255:	83 ec 0c             	sub    $0xc,%esp
f0101258:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f010125c:	53                   	push   %ebx
f010125d:	ff 75 d0             	pushl  -0x30(%ebp)
f0101260:	50                   	push   %eax
f0101261:	51                   	push   %ecx
f0101262:	52                   	push   %edx
f0101263:	89 fa                	mov    %edi,%edx
f0101265:	89 f0                	mov    %esi,%eax
f0101267:	e8 40 fb ff ff       	call   f0100dac <printnum>
			break;
f010126c:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010126f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101272:	83 c3 01             	add    $0x1,%ebx
f0101275:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101279:	83 f8 25             	cmp    $0x25,%eax
f010127c:	0f 84 5b fc ff ff    	je     f0100edd <vprintfmt+0x31>
			if (ch == '\0')
f0101282:	85 c0                	test   %eax,%eax
f0101284:	0f 84 97 00 00 00    	je     f0101321 <.L20+0x23>
			putch(ch, putdat);
f010128a:	83 ec 08             	sub    $0x8,%esp
f010128d:	57                   	push   %edi
f010128e:	50                   	push   %eax
f010128f:	ff d6                	call   *%esi
f0101291:	83 c4 10             	add    $0x10,%esp
f0101294:	eb dc                	jmp    f0101272 <.L25+0x48>

f0101296 <.L21>:
f0101296:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101299:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010129c:	83 f9 01             	cmp    $0x1,%ecx
f010129f:	7f 1b                	jg     f01012bc <.L21+0x26>
	else if (lflag)
f01012a1:	85 c9                	test   %ecx,%ecx
f01012a3:	74 2c                	je     f01012d1 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01012a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a8:	8b 10                	mov    (%eax),%edx
f01012aa:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012af:	8d 40 04             	lea    0x4(%eax),%eax
f01012b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01012b5:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f01012ba:	eb 99                	jmp    f0101255 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01012bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01012bf:	8b 10                	mov    (%eax),%edx
f01012c1:	8b 48 04             	mov    0x4(%eax),%ecx
f01012c4:	8d 40 08             	lea    0x8(%eax),%eax
f01012c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01012ca:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f01012cf:	eb 84                	jmp    f0101255 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01012d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d4:	8b 10                	mov    (%eax),%edx
f01012d6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012db:	8d 40 04             	lea    0x4(%eax),%eax
f01012de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01012e1:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f01012e6:	e9 6a ff ff ff       	jmp    f0101255 <.L25+0x2b>

f01012eb <.L35>:
f01012eb:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f01012ee:	83 ec 08             	sub    $0x8,%esp
f01012f1:	57                   	push   %edi
f01012f2:	6a 25                	push   $0x25
f01012f4:	ff d6                	call   *%esi
			break;
f01012f6:	83 c4 10             	add    $0x10,%esp
f01012f9:	e9 71 ff ff ff       	jmp    f010126f <.L25+0x45>

f01012fe <.L20>:
f01012fe:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f0101301:	83 ec 08             	sub    $0x8,%esp
f0101304:	57                   	push   %edi
f0101305:	6a 25                	push   $0x25
f0101307:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101309:	83 c4 10             	add    $0x10,%esp
f010130c:	89 d8                	mov    %ebx,%eax
f010130e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101312:	74 05                	je     f0101319 <.L20+0x1b>
f0101314:	83 e8 01             	sub    $0x1,%eax
f0101317:	eb f5                	jmp    f010130e <.L20+0x10>
f0101319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010131c:	e9 4e ff ff ff       	jmp    f010126f <.L25+0x45>
}
f0101321:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101324:	5b                   	pop    %ebx
f0101325:	5e                   	pop    %esi
f0101326:	5f                   	pop    %edi
f0101327:	5d                   	pop    %ebp
f0101328:	c3                   	ret    

f0101329 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101329:	f3 0f 1e fb          	endbr32 
f010132d:	55                   	push   %ebp
f010132e:	89 e5                	mov    %esp,%ebp
f0101330:	53                   	push   %ebx
f0101331:	83 ec 14             	sub    $0x14,%esp
f0101334:	e8 93 ee ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0101339:	81 c3 cf ff 00 00    	add    $0xffcf,%ebx
f010133f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101342:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101345:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101348:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010134c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010134f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101356:	85 c0                	test   %eax,%eax
f0101358:	74 2b                	je     f0101385 <vsnprintf+0x5c>
f010135a:	85 d2                	test   %edx,%edx
f010135c:	7e 27                	jle    f0101385 <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010135e:	ff 75 14             	pushl  0x14(%ebp)
f0101361:	ff 75 10             	pushl  0x10(%ebp)
f0101364:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101367:	50                   	push   %eax
f0101368:	8d 83 62 fb fe ff    	lea    -0x1049e(%ebx),%eax
f010136e:	50                   	push   %eax
f010136f:	e8 38 fb ff ff       	call   f0100eac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101374:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101377:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010137a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010137d:	83 c4 10             	add    $0x10,%esp
}
f0101380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101383:	c9                   	leave  
f0101384:	c3                   	ret    
		return -E_INVAL;
f0101385:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010138a:	eb f4                	jmp    f0101380 <vsnprintf+0x57>

f010138c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010138c:	f3 0f 1e fb          	endbr32 
f0101390:	55                   	push   %ebp
f0101391:	89 e5                	mov    %esp,%ebp
f0101393:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101396:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101399:	50                   	push   %eax
f010139a:	ff 75 10             	pushl  0x10(%ebp)
f010139d:	ff 75 0c             	pushl  0xc(%ebp)
f01013a0:	ff 75 08             	pushl  0x8(%ebp)
f01013a3:	e8 81 ff ff ff       	call   f0101329 <vsnprintf>
	va_end(ap);

	return rc;
}
f01013a8:	c9                   	leave  
f01013a9:	c3                   	ret    

f01013aa <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01013aa:	f3 0f 1e fb          	endbr32 
f01013ae:	55                   	push   %ebp
f01013af:	89 e5                	mov    %esp,%ebp
f01013b1:	57                   	push   %edi
f01013b2:	56                   	push   %esi
f01013b3:	53                   	push   %ebx
f01013b4:	83 ec 1c             	sub    $0x1c,%esp
f01013b7:	e8 10 ee ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01013bc:	81 c3 4c ff 00 00    	add    $0xff4c,%ebx
f01013c2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01013c5:	85 c0                	test   %eax,%eax
f01013c7:	74 13                	je     f01013dc <readline+0x32>
		cprintf("%s", prompt);
f01013c9:	83 ec 08             	sub    $0x8,%esp
f01013cc:	50                   	push   %eax
f01013cd:	8d 83 bf 0c ff ff    	lea    -0xf341(%ebx),%eax
f01013d3:	50                   	push   %eax
f01013d4:	e8 b4 f6 ff ff       	call   f0100a8d <cprintf>
f01013d9:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01013dc:	83 ec 0c             	sub    $0xc,%esp
f01013df:	6a 00                	push   $0x0
f01013e1:	e8 90 f3 ff ff       	call   f0100776 <iscons>
f01013e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013e9:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01013ec:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f01013f1:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01013f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01013fa:	eb 51                	jmp    f010144d <readline+0xa3>
			cprintf("read error: %e\n", c);
f01013fc:	83 ec 08             	sub    $0x8,%esp
f01013ff:	50                   	push   %eax
f0101400:	8d 83 84 0e ff ff    	lea    -0xf17c(%ebx),%eax
f0101406:	50                   	push   %eax
f0101407:	e8 81 f6 ff ff       	call   f0100a8d <cprintf>
			return NULL;
f010140c:	83 c4 10             	add    $0x10,%esp
f010140f:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101414:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101417:	5b                   	pop    %ebx
f0101418:	5e                   	pop    %esi
f0101419:	5f                   	pop    %edi
f010141a:	5d                   	pop    %ebp
f010141b:	c3                   	ret    
			if (echoing)
f010141c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101420:	75 05                	jne    f0101427 <readline+0x7d>
			i--;
f0101422:	83 ef 01             	sub    $0x1,%edi
f0101425:	eb 26                	jmp    f010144d <readline+0xa3>
				cputchar('\b');
f0101427:	83 ec 0c             	sub    $0xc,%esp
f010142a:	6a 08                	push   $0x8
f010142c:	e8 1c f3 ff ff       	call   f010074d <cputchar>
f0101431:	83 c4 10             	add    $0x10,%esp
f0101434:	eb ec                	jmp    f0101422 <readline+0x78>
				cputchar(c);
f0101436:	83 ec 0c             	sub    $0xc,%esp
f0101439:	56                   	push   %esi
f010143a:	e8 0e f3 ff ff       	call   f010074d <cputchar>
f010143f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101442:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101445:	89 f0                	mov    %esi,%eax
f0101447:	88 04 39             	mov    %al,(%ecx,%edi,1)
f010144a:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010144d:	e8 0f f3 ff ff       	call   f0100761 <getchar>
f0101452:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101454:	85 c0                	test   %eax,%eax
f0101456:	78 a4                	js     f01013fc <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101458:	83 f8 08             	cmp    $0x8,%eax
f010145b:	0f 94 c2             	sete   %dl
f010145e:	83 f8 7f             	cmp    $0x7f,%eax
f0101461:	0f 94 c0             	sete   %al
f0101464:	08 c2                	or     %al,%dl
f0101466:	74 04                	je     f010146c <readline+0xc2>
f0101468:	85 ff                	test   %edi,%edi
f010146a:	7f b0                	jg     f010141c <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010146c:	83 fe 1f             	cmp    $0x1f,%esi
f010146f:	7e 10                	jle    f0101481 <readline+0xd7>
f0101471:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101477:	7f 08                	jg     f0101481 <readline+0xd7>
			if (echoing)
f0101479:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010147d:	74 c3                	je     f0101442 <readline+0x98>
f010147f:	eb b5                	jmp    f0101436 <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f0101481:	83 fe 0a             	cmp    $0xa,%esi
f0101484:	74 05                	je     f010148b <readline+0xe1>
f0101486:	83 fe 0d             	cmp    $0xd,%esi
f0101489:	75 c2                	jne    f010144d <readline+0xa3>
			if (echoing)
f010148b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010148f:	75 13                	jne    f01014a4 <readline+0xfa>
			buf[i] = 0;
f0101491:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0101498:	00 
			return buf;
f0101499:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f010149f:	e9 70 ff ff ff       	jmp    f0101414 <readline+0x6a>
				cputchar('\n');
f01014a4:	83 ec 0c             	sub    $0xc,%esp
f01014a7:	6a 0a                	push   $0xa
f01014a9:	e8 9f f2 ff ff       	call   f010074d <cputchar>
f01014ae:	83 c4 10             	add    $0x10,%esp
f01014b1:	eb de                	jmp    f0101491 <readline+0xe7>

f01014b3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01014b3:	f3 0f 1e fb          	endbr32 
f01014b7:	55                   	push   %ebp
f01014b8:	89 e5                	mov    %esp,%ebp
f01014ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01014bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01014c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01014c6:	74 05                	je     f01014cd <strlen+0x1a>
		n++;
f01014c8:	83 c0 01             	add    $0x1,%eax
f01014cb:	eb f5                	jmp    f01014c2 <strlen+0xf>
	return n;
}
f01014cd:	5d                   	pop    %ebp
f01014ce:	c3                   	ret    

f01014cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01014cf:	f3 0f 1e fb          	endbr32 
f01014d3:	55                   	push   %ebp
f01014d4:	89 e5                	mov    %esp,%ebp
f01014d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01014d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01014dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01014e1:	39 d0                	cmp    %edx,%eax
f01014e3:	74 0d                	je     f01014f2 <strnlen+0x23>
f01014e5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01014e9:	74 05                	je     f01014f0 <strnlen+0x21>
		n++;
f01014eb:	83 c0 01             	add    $0x1,%eax
f01014ee:	eb f1                	jmp    f01014e1 <strnlen+0x12>
f01014f0:	89 c2                	mov    %eax,%edx
	return n;
}
f01014f2:	89 d0                	mov    %edx,%eax
f01014f4:	5d                   	pop    %ebp
f01014f5:	c3                   	ret    

f01014f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01014f6:	f3 0f 1e fb          	endbr32 
f01014fa:	55                   	push   %ebp
f01014fb:	89 e5                	mov    %esp,%ebp
f01014fd:	53                   	push   %ebx
f01014fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101504:	b8 00 00 00 00       	mov    $0x0,%eax
f0101509:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f010150d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0101510:	83 c0 01             	add    $0x1,%eax
f0101513:	84 d2                	test   %dl,%dl
f0101515:	75 f2                	jne    f0101509 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0101517:	89 c8                	mov    %ecx,%eax
f0101519:	5b                   	pop    %ebx
f010151a:	5d                   	pop    %ebp
f010151b:	c3                   	ret    

f010151c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010151c:	f3 0f 1e fb          	endbr32 
f0101520:	55                   	push   %ebp
f0101521:	89 e5                	mov    %esp,%ebp
f0101523:	53                   	push   %ebx
f0101524:	83 ec 10             	sub    $0x10,%esp
f0101527:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010152a:	53                   	push   %ebx
f010152b:	e8 83 ff ff ff       	call   f01014b3 <strlen>
f0101530:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0101533:	ff 75 0c             	pushl  0xc(%ebp)
f0101536:	01 d8                	add    %ebx,%eax
f0101538:	50                   	push   %eax
f0101539:	e8 b8 ff ff ff       	call   f01014f6 <strcpy>
	return dst;
}
f010153e:	89 d8                	mov    %ebx,%eax
f0101540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101543:	c9                   	leave  
f0101544:	c3                   	ret    

f0101545 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101545:	f3 0f 1e fb          	endbr32 
f0101549:	55                   	push   %ebp
f010154a:	89 e5                	mov    %esp,%ebp
f010154c:	56                   	push   %esi
f010154d:	53                   	push   %ebx
f010154e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101551:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101554:	89 f3                	mov    %esi,%ebx
f0101556:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101559:	89 f0                	mov    %esi,%eax
f010155b:	39 d8                	cmp    %ebx,%eax
f010155d:	74 11                	je     f0101570 <strncpy+0x2b>
		*dst++ = *src;
f010155f:	83 c0 01             	add    $0x1,%eax
f0101562:	0f b6 0a             	movzbl (%edx),%ecx
f0101565:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101568:	80 f9 01             	cmp    $0x1,%cl
f010156b:	83 da ff             	sbb    $0xffffffff,%edx
f010156e:	eb eb                	jmp    f010155b <strncpy+0x16>
	}
	return ret;
}
f0101570:	89 f0                	mov    %esi,%eax
f0101572:	5b                   	pop    %ebx
f0101573:	5e                   	pop    %esi
f0101574:	5d                   	pop    %ebp
f0101575:	c3                   	ret    

f0101576 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101576:	f3 0f 1e fb          	endbr32 
f010157a:	55                   	push   %ebp
f010157b:	89 e5                	mov    %esp,%ebp
f010157d:	56                   	push   %esi
f010157e:	53                   	push   %ebx
f010157f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101582:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101585:	8b 55 10             	mov    0x10(%ebp),%edx
f0101588:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010158a:	85 d2                	test   %edx,%edx
f010158c:	74 21                	je     f01015af <strlcpy+0x39>
f010158e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101592:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0101594:	39 c2                	cmp    %eax,%edx
f0101596:	74 14                	je     f01015ac <strlcpy+0x36>
f0101598:	0f b6 19             	movzbl (%ecx),%ebx
f010159b:	84 db                	test   %bl,%bl
f010159d:	74 0b                	je     f01015aa <strlcpy+0x34>
			*dst++ = *src++;
f010159f:	83 c1 01             	add    $0x1,%ecx
f01015a2:	83 c2 01             	add    $0x1,%edx
f01015a5:	88 5a ff             	mov    %bl,-0x1(%edx)
f01015a8:	eb ea                	jmp    f0101594 <strlcpy+0x1e>
f01015aa:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01015ac:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01015af:	29 f0                	sub    %esi,%eax
}
f01015b1:	5b                   	pop    %ebx
f01015b2:	5e                   	pop    %esi
f01015b3:	5d                   	pop    %ebp
f01015b4:	c3                   	ret    

f01015b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01015b5:	f3 0f 1e fb          	endbr32 
f01015b9:	55                   	push   %ebp
f01015ba:	89 e5                	mov    %esp,%ebp
f01015bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01015c2:	0f b6 01             	movzbl (%ecx),%eax
f01015c5:	84 c0                	test   %al,%al
f01015c7:	74 0c                	je     f01015d5 <strcmp+0x20>
f01015c9:	3a 02                	cmp    (%edx),%al
f01015cb:	75 08                	jne    f01015d5 <strcmp+0x20>
		p++, q++;
f01015cd:	83 c1 01             	add    $0x1,%ecx
f01015d0:	83 c2 01             	add    $0x1,%edx
f01015d3:	eb ed                	jmp    f01015c2 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01015d5:	0f b6 c0             	movzbl %al,%eax
f01015d8:	0f b6 12             	movzbl (%edx),%edx
f01015db:	29 d0                	sub    %edx,%eax
}
f01015dd:	5d                   	pop    %ebp
f01015de:	c3                   	ret    

f01015df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01015df:	f3 0f 1e fb          	endbr32 
f01015e3:	55                   	push   %ebp
f01015e4:	89 e5                	mov    %esp,%ebp
f01015e6:	53                   	push   %ebx
f01015e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ea:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015ed:	89 c3                	mov    %eax,%ebx
f01015ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01015f2:	eb 06                	jmp    f01015fa <strncmp+0x1b>
		n--, p++, q++;
f01015f4:	83 c0 01             	add    $0x1,%eax
f01015f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01015fa:	39 d8                	cmp    %ebx,%eax
f01015fc:	74 16                	je     f0101614 <strncmp+0x35>
f01015fe:	0f b6 08             	movzbl (%eax),%ecx
f0101601:	84 c9                	test   %cl,%cl
f0101603:	74 04                	je     f0101609 <strncmp+0x2a>
f0101605:	3a 0a                	cmp    (%edx),%cl
f0101607:	74 eb                	je     f01015f4 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101609:	0f b6 00             	movzbl (%eax),%eax
f010160c:	0f b6 12             	movzbl (%edx),%edx
f010160f:	29 d0                	sub    %edx,%eax
}
f0101611:	5b                   	pop    %ebx
f0101612:	5d                   	pop    %ebp
f0101613:	c3                   	ret    
		return 0;
f0101614:	b8 00 00 00 00       	mov    $0x0,%eax
f0101619:	eb f6                	jmp    f0101611 <strncmp+0x32>

f010161b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010161b:	f3 0f 1e fb          	endbr32 
f010161f:	55                   	push   %ebp
f0101620:	89 e5                	mov    %esp,%ebp
f0101622:	8b 45 08             	mov    0x8(%ebp),%eax
f0101625:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101629:	0f b6 10             	movzbl (%eax),%edx
f010162c:	84 d2                	test   %dl,%dl
f010162e:	74 09                	je     f0101639 <strchr+0x1e>
		if (*s == c)
f0101630:	38 ca                	cmp    %cl,%dl
f0101632:	74 0a                	je     f010163e <strchr+0x23>
	for (; *s; s++)
f0101634:	83 c0 01             	add    $0x1,%eax
f0101637:	eb f0                	jmp    f0101629 <strchr+0xe>
			return (char *) s;
	return 0;
f0101639:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010163e:	5d                   	pop    %ebp
f010163f:	c3                   	ret    

f0101640 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101640:	f3 0f 1e fb          	endbr32 
f0101644:	55                   	push   %ebp
f0101645:	89 e5                	mov    %esp,%ebp
f0101647:	8b 45 08             	mov    0x8(%ebp),%eax
f010164a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010164e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101651:	38 ca                	cmp    %cl,%dl
f0101653:	74 09                	je     f010165e <strfind+0x1e>
f0101655:	84 d2                	test   %dl,%dl
f0101657:	74 05                	je     f010165e <strfind+0x1e>
	for (; *s; s++)
f0101659:	83 c0 01             	add    $0x1,%eax
f010165c:	eb f0                	jmp    f010164e <strfind+0xe>
			break;
	return (char *) s;
}
f010165e:	5d                   	pop    %ebp
f010165f:	c3                   	ret    

f0101660 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101660:	f3 0f 1e fb          	endbr32 
f0101664:	55                   	push   %ebp
f0101665:	89 e5                	mov    %esp,%ebp
f0101667:	57                   	push   %edi
f0101668:	56                   	push   %esi
f0101669:	53                   	push   %ebx
f010166a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010166d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101670:	85 c9                	test   %ecx,%ecx
f0101672:	74 31                	je     f01016a5 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101674:	89 f8                	mov    %edi,%eax
f0101676:	09 c8                	or     %ecx,%eax
f0101678:	a8 03                	test   $0x3,%al
f010167a:	75 23                	jne    f010169f <memset+0x3f>
		c &= 0xFF;
f010167c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101680:	89 d3                	mov    %edx,%ebx
f0101682:	c1 e3 08             	shl    $0x8,%ebx
f0101685:	89 d0                	mov    %edx,%eax
f0101687:	c1 e0 18             	shl    $0x18,%eax
f010168a:	89 d6                	mov    %edx,%esi
f010168c:	c1 e6 10             	shl    $0x10,%esi
f010168f:	09 f0                	or     %esi,%eax
f0101691:	09 c2                	or     %eax,%edx
f0101693:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101695:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101698:	89 d0                	mov    %edx,%eax
f010169a:	fc                   	cld    
f010169b:	f3 ab                	rep stos %eax,%es:(%edi)
f010169d:	eb 06                	jmp    f01016a5 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010169f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016a2:	fc                   	cld    
f01016a3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01016a5:	89 f8                	mov    %edi,%eax
f01016a7:	5b                   	pop    %ebx
f01016a8:	5e                   	pop    %esi
f01016a9:	5f                   	pop    %edi
f01016aa:	5d                   	pop    %ebp
f01016ab:	c3                   	ret    

f01016ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01016ac:	f3 0f 1e fb          	endbr32 
f01016b0:	55                   	push   %ebp
f01016b1:	89 e5                	mov    %esp,%ebp
f01016b3:	57                   	push   %edi
f01016b4:	56                   	push   %esi
f01016b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01016b8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01016be:	39 c6                	cmp    %eax,%esi
f01016c0:	73 32                	jae    f01016f4 <memmove+0x48>
f01016c2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01016c5:	39 c2                	cmp    %eax,%edx
f01016c7:	76 2b                	jbe    f01016f4 <memmove+0x48>
		s += n;
		d += n;
f01016c9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01016cc:	89 fe                	mov    %edi,%esi
f01016ce:	09 ce                	or     %ecx,%esi
f01016d0:	09 d6                	or     %edx,%esi
f01016d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01016d8:	75 0e                	jne    f01016e8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01016da:	83 ef 04             	sub    $0x4,%edi
f01016dd:	8d 72 fc             	lea    -0x4(%edx),%esi
f01016e0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01016e3:	fd                   	std    
f01016e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01016e6:	eb 09                	jmp    f01016f1 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01016e8:	83 ef 01             	sub    $0x1,%edi
f01016eb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01016ee:	fd                   	std    
f01016ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01016f1:	fc                   	cld    
f01016f2:	eb 1a                	jmp    f010170e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01016f4:	89 c2                	mov    %eax,%edx
f01016f6:	09 ca                	or     %ecx,%edx
f01016f8:	09 f2                	or     %esi,%edx
f01016fa:	f6 c2 03             	test   $0x3,%dl
f01016fd:	75 0a                	jne    f0101709 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01016ff:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101702:	89 c7                	mov    %eax,%edi
f0101704:	fc                   	cld    
f0101705:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101707:	eb 05                	jmp    f010170e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0101709:	89 c7                	mov    %eax,%edi
f010170b:	fc                   	cld    
f010170c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010170e:	5e                   	pop    %esi
f010170f:	5f                   	pop    %edi
f0101710:	5d                   	pop    %ebp
f0101711:	c3                   	ret    

f0101712 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101712:	f3 0f 1e fb          	endbr32 
f0101716:	55                   	push   %ebp
f0101717:	89 e5                	mov    %esp,%ebp
f0101719:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010171c:	ff 75 10             	pushl  0x10(%ebp)
f010171f:	ff 75 0c             	pushl  0xc(%ebp)
f0101722:	ff 75 08             	pushl  0x8(%ebp)
f0101725:	e8 82 ff ff ff       	call   f01016ac <memmove>
}
f010172a:	c9                   	leave  
f010172b:	c3                   	ret    

f010172c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010172c:	f3 0f 1e fb          	endbr32 
f0101730:	55                   	push   %ebp
f0101731:	89 e5                	mov    %esp,%ebp
f0101733:	56                   	push   %esi
f0101734:	53                   	push   %ebx
f0101735:	8b 45 08             	mov    0x8(%ebp),%eax
f0101738:	8b 55 0c             	mov    0xc(%ebp),%edx
f010173b:	89 c6                	mov    %eax,%esi
f010173d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101740:	39 f0                	cmp    %esi,%eax
f0101742:	74 1c                	je     f0101760 <memcmp+0x34>
		if (*s1 != *s2)
f0101744:	0f b6 08             	movzbl (%eax),%ecx
f0101747:	0f b6 1a             	movzbl (%edx),%ebx
f010174a:	38 d9                	cmp    %bl,%cl
f010174c:	75 08                	jne    f0101756 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010174e:	83 c0 01             	add    $0x1,%eax
f0101751:	83 c2 01             	add    $0x1,%edx
f0101754:	eb ea                	jmp    f0101740 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0101756:	0f b6 c1             	movzbl %cl,%eax
f0101759:	0f b6 db             	movzbl %bl,%ebx
f010175c:	29 d8                	sub    %ebx,%eax
f010175e:	eb 05                	jmp    f0101765 <memcmp+0x39>
	}

	return 0;
f0101760:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101765:	5b                   	pop    %ebx
f0101766:	5e                   	pop    %esi
f0101767:	5d                   	pop    %ebp
f0101768:	c3                   	ret    

f0101769 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101769:	f3 0f 1e fb          	endbr32 
f010176d:	55                   	push   %ebp
f010176e:	89 e5                	mov    %esp,%ebp
f0101770:	8b 45 08             	mov    0x8(%ebp),%eax
f0101773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101776:	89 c2                	mov    %eax,%edx
f0101778:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010177b:	39 d0                	cmp    %edx,%eax
f010177d:	73 09                	jae    f0101788 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f010177f:	38 08                	cmp    %cl,(%eax)
f0101781:	74 05                	je     f0101788 <memfind+0x1f>
	for (; s < ends; s++)
f0101783:	83 c0 01             	add    $0x1,%eax
f0101786:	eb f3                	jmp    f010177b <memfind+0x12>
			break;
	return (void *) s;
}
f0101788:	5d                   	pop    %ebp
f0101789:	c3                   	ret    

f010178a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010178a:	f3 0f 1e fb          	endbr32 
f010178e:	55                   	push   %ebp
f010178f:	89 e5                	mov    %esp,%ebp
f0101791:	57                   	push   %edi
f0101792:	56                   	push   %esi
f0101793:	53                   	push   %ebx
f0101794:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101797:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010179a:	eb 03                	jmp    f010179f <strtol+0x15>
		s++;
f010179c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010179f:	0f b6 01             	movzbl (%ecx),%eax
f01017a2:	3c 20                	cmp    $0x20,%al
f01017a4:	74 f6                	je     f010179c <strtol+0x12>
f01017a6:	3c 09                	cmp    $0x9,%al
f01017a8:	74 f2                	je     f010179c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f01017aa:	3c 2b                	cmp    $0x2b,%al
f01017ac:	74 2a                	je     f01017d8 <strtol+0x4e>
	int neg = 0;
f01017ae:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01017b3:	3c 2d                	cmp    $0x2d,%al
f01017b5:	74 2b                	je     f01017e2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01017b7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01017bd:	75 0f                	jne    f01017ce <strtol+0x44>
f01017bf:	80 39 30             	cmpb   $0x30,(%ecx)
f01017c2:	74 28                	je     f01017ec <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01017c4:	85 db                	test   %ebx,%ebx
f01017c6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01017cb:	0f 44 d8             	cmove  %eax,%ebx
f01017ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01017d3:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01017d6:	eb 46                	jmp    f010181e <strtol+0x94>
		s++;
f01017d8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01017db:	bf 00 00 00 00       	mov    $0x0,%edi
f01017e0:	eb d5                	jmp    f01017b7 <strtol+0x2d>
		s++, neg = 1;
f01017e2:	83 c1 01             	add    $0x1,%ecx
f01017e5:	bf 01 00 00 00       	mov    $0x1,%edi
f01017ea:	eb cb                	jmp    f01017b7 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01017ec:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01017f0:	74 0e                	je     f0101800 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01017f2:	85 db                	test   %ebx,%ebx
f01017f4:	75 d8                	jne    f01017ce <strtol+0x44>
		s++, base = 8;
f01017f6:	83 c1 01             	add    $0x1,%ecx
f01017f9:	bb 08 00 00 00       	mov    $0x8,%ebx
f01017fe:	eb ce                	jmp    f01017ce <strtol+0x44>
		s += 2, base = 16;
f0101800:	83 c1 02             	add    $0x2,%ecx
f0101803:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101808:	eb c4                	jmp    f01017ce <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f010180a:	0f be d2             	movsbl %dl,%edx
f010180d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101810:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101813:	7d 3a                	jge    f010184f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101815:	83 c1 01             	add    $0x1,%ecx
f0101818:	0f af 45 10          	imul   0x10(%ebp),%eax
f010181c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010181e:	0f b6 11             	movzbl (%ecx),%edx
f0101821:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101824:	89 f3                	mov    %esi,%ebx
f0101826:	80 fb 09             	cmp    $0x9,%bl
f0101829:	76 df                	jbe    f010180a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f010182b:	8d 72 9f             	lea    -0x61(%edx),%esi
f010182e:	89 f3                	mov    %esi,%ebx
f0101830:	80 fb 19             	cmp    $0x19,%bl
f0101833:	77 08                	ja     f010183d <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101835:	0f be d2             	movsbl %dl,%edx
f0101838:	83 ea 57             	sub    $0x57,%edx
f010183b:	eb d3                	jmp    f0101810 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f010183d:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101840:	89 f3                	mov    %esi,%ebx
f0101842:	80 fb 19             	cmp    $0x19,%bl
f0101845:	77 08                	ja     f010184f <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101847:	0f be d2             	movsbl %dl,%edx
f010184a:	83 ea 37             	sub    $0x37,%edx
f010184d:	eb c1                	jmp    f0101810 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f010184f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101853:	74 05                	je     f010185a <strtol+0xd0>
		*endptr = (char *) s;
f0101855:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101858:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010185a:	89 c2                	mov    %eax,%edx
f010185c:	f7 da                	neg    %edx
f010185e:	85 ff                	test   %edi,%edi
f0101860:	0f 45 c2             	cmovne %edx,%eax
}
f0101863:	5b                   	pop    %ebx
f0101864:	5e                   	pop    %esi
f0101865:	5f                   	pop    %edi
f0101866:	5d                   	pop    %ebp
f0101867:	c3                   	ret    
f0101868:	66 90                	xchg   %ax,%ax
f010186a:	66 90                	xchg   %ax,%ax
f010186c:	66 90                	xchg   %ax,%ax
f010186e:	66 90                	xchg   %ax,%ax

f0101870 <__udivdi3>:
f0101870:	f3 0f 1e fb          	endbr32 
f0101874:	55                   	push   %ebp
f0101875:	57                   	push   %edi
f0101876:	56                   	push   %esi
f0101877:	53                   	push   %ebx
f0101878:	83 ec 1c             	sub    $0x1c,%esp
f010187b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010187f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101883:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101887:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010188b:	85 d2                	test   %edx,%edx
f010188d:	75 19                	jne    f01018a8 <__udivdi3+0x38>
f010188f:	39 f3                	cmp    %esi,%ebx
f0101891:	76 4d                	jbe    f01018e0 <__udivdi3+0x70>
f0101893:	31 ff                	xor    %edi,%edi
f0101895:	89 e8                	mov    %ebp,%eax
f0101897:	89 f2                	mov    %esi,%edx
f0101899:	f7 f3                	div    %ebx
f010189b:	89 fa                	mov    %edi,%edx
f010189d:	83 c4 1c             	add    $0x1c,%esp
f01018a0:	5b                   	pop    %ebx
f01018a1:	5e                   	pop    %esi
f01018a2:	5f                   	pop    %edi
f01018a3:	5d                   	pop    %ebp
f01018a4:	c3                   	ret    
f01018a5:	8d 76 00             	lea    0x0(%esi),%esi
f01018a8:	39 f2                	cmp    %esi,%edx
f01018aa:	76 14                	jbe    f01018c0 <__udivdi3+0x50>
f01018ac:	31 ff                	xor    %edi,%edi
f01018ae:	31 c0                	xor    %eax,%eax
f01018b0:	89 fa                	mov    %edi,%edx
f01018b2:	83 c4 1c             	add    $0x1c,%esp
f01018b5:	5b                   	pop    %ebx
f01018b6:	5e                   	pop    %esi
f01018b7:	5f                   	pop    %edi
f01018b8:	5d                   	pop    %ebp
f01018b9:	c3                   	ret    
f01018ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018c0:	0f bd fa             	bsr    %edx,%edi
f01018c3:	83 f7 1f             	xor    $0x1f,%edi
f01018c6:	75 48                	jne    f0101910 <__udivdi3+0xa0>
f01018c8:	39 f2                	cmp    %esi,%edx
f01018ca:	72 06                	jb     f01018d2 <__udivdi3+0x62>
f01018cc:	31 c0                	xor    %eax,%eax
f01018ce:	39 eb                	cmp    %ebp,%ebx
f01018d0:	77 de                	ja     f01018b0 <__udivdi3+0x40>
f01018d2:	b8 01 00 00 00       	mov    $0x1,%eax
f01018d7:	eb d7                	jmp    f01018b0 <__udivdi3+0x40>
f01018d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018e0:	89 d9                	mov    %ebx,%ecx
f01018e2:	85 db                	test   %ebx,%ebx
f01018e4:	75 0b                	jne    f01018f1 <__udivdi3+0x81>
f01018e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01018eb:	31 d2                	xor    %edx,%edx
f01018ed:	f7 f3                	div    %ebx
f01018ef:	89 c1                	mov    %eax,%ecx
f01018f1:	31 d2                	xor    %edx,%edx
f01018f3:	89 f0                	mov    %esi,%eax
f01018f5:	f7 f1                	div    %ecx
f01018f7:	89 c6                	mov    %eax,%esi
f01018f9:	89 e8                	mov    %ebp,%eax
f01018fb:	89 f7                	mov    %esi,%edi
f01018fd:	f7 f1                	div    %ecx
f01018ff:	89 fa                	mov    %edi,%edx
f0101901:	83 c4 1c             	add    $0x1c,%esp
f0101904:	5b                   	pop    %ebx
f0101905:	5e                   	pop    %esi
f0101906:	5f                   	pop    %edi
f0101907:	5d                   	pop    %ebp
f0101908:	c3                   	ret    
f0101909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101910:	89 f9                	mov    %edi,%ecx
f0101912:	b8 20 00 00 00       	mov    $0x20,%eax
f0101917:	29 f8                	sub    %edi,%eax
f0101919:	d3 e2                	shl    %cl,%edx
f010191b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010191f:	89 c1                	mov    %eax,%ecx
f0101921:	89 da                	mov    %ebx,%edx
f0101923:	d3 ea                	shr    %cl,%edx
f0101925:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101929:	09 d1                	or     %edx,%ecx
f010192b:	89 f2                	mov    %esi,%edx
f010192d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101931:	89 f9                	mov    %edi,%ecx
f0101933:	d3 e3                	shl    %cl,%ebx
f0101935:	89 c1                	mov    %eax,%ecx
f0101937:	d3 ea                	shr    %cl,%edx
f0101939:	89 f9                	mov    %edi,%ecx
f010193b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010193f:	89 eb                	mov    %ebp,%ebx
f0101941:	d3 e6                	shl    %cl,%esi
f0101943:	89 c1                	mov    %eax,%ecx
f0101945:	d3 eb                	shr    %cl,%ebx
f0101947:	09 de                	or     %ebx,%esi
f0101949:	89 f0                	mov    %esi,%eax
f010194b:	f7 74 24 08          	divl   0x8(%esp)
f010194f:	89 d6                	mov    %edx,%esi
f0101951:	89 c3                	mov    %eax,%ebx
f0101953:	f7 64 24 0c          	mull   0xc(%esp)
f0101957:	39 d6                	cmp    %edx,%esi
f0101959:	72 15                	jb     f0101970 <__udivdi3+0x100>
f010195b:	89 f9                	mov    %edi,%ecx
f010195d:	d3 e5                	shl    %cl,%ebp
f010195f:	39 c5                	cmp    %eax,%ebp
f0101961:	73 04                	jae    f0101967 <__udivdi3+0xf7>
f0101963:	39 d6                	cmp    %edx,%esi
f0101965:	74 09                	je     f0101970 <__udivdi3+0x100>
f0101967:	89 d8                	mov    %ebx,%eax
f0101969:	31 ff                	xor    %edi,%edi
f010196b:	e9 40 ff ff ff       	jmp    f01018b0 <__udivdi3+0x40>
f0101970:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101973:	31 ff                	xor    %edi,%edi
f0101975:	e9 36 ff ff ff       	jmp    f01018b0 <__udivdi3+0x40>
f010197a:	66 90                	xchg   %ax,%ax
f010197c:	66 90                	xchg   %ax,%ax
f010197e:	66 90                	xchg   %ax,%ax

f0101980 <__umoddi3>:
f0101980:	f3 0f 1e fb          	endbr32 
f0101984:	55                   	push   %ebp
f0101985:	57                   	push   %edi
f0101986:	56                   	push   %esi
f0101987:	53                   	push   %ebx
f0101988:	83 ec 1c             	sub    $0x1c,%esp
f010198b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010198f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101993:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101997:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010199b:	85 c0                	test   %eax,%eax
f010199d:	75 19                	jne    f01019b8 <__umoddi3+0x38>
f010199f:	39 df                	cmp    %ebx,%edi
f01019a1:	76 5d                	jbe    f0101a00 <__umoddi3+0x80>
f01019a3:	89 f0                	mov    %esi,%eax
f01019a5:	89 da                	mov    %ebx,%edx
f01019a7:	f7 f7                	div    %edi
f01019a9:	89 d0                	mov    %edx,%eax
f01019ab:	31 d2                	xor    %edx,%edx
f01019ad:	83 c4 1c             	add    $0x1c,%esp
f01019b0:	5b                   	pop    %ebx
f01019b1:	5e                   	pop    %esi
f01019b2:	5f                   	pop    %edi
f01019b3:	5d                   	pop    %ebp
f01019b4:	c3                   	ret    
f01019b5:	8d 76 00             	lea    0x0(%esi),%esi
f01019b8:	89 f2                	mov    %esi,%edx
f01019ba:	39 d8                	cmp    %ebx,%eax
f01019bc:	76 12                	jbe    f01019d0 <__umoddi3+0x50>
f01019be:	89 f0                	mov    %esi,%eax
f01019c0:	89 da                	mov    %ebx,%edx
f01019c2:	83 c4 1c             	add    $0x1c,%esp
f01019c5:	5b                   	pop    %ebx
f01019c6:	5e                   	pop    %esi
f01019c7:	5f                   	pop    %edi
f01019c8:	5d                   	pop    %ebp
f01019c9:	c3                   	ret    
f01019ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01019d0:	0f bd e8             	bsr    %eax,%ebp
f01019d3:	83 f5 1f             	xor    $0x1f,%ebp
f01019d6:	75 50                	jne    f0101a28 <__umoddi3+0xa8>
f01019d8:	39 d8                	cmp    %ebx,%eax
f01019da:	0f 82 e0 00 00 00    	jb     f0101ac0 <__umoddi3+0x140>
f01019e0:	89 d9                	mov    %ebx,%ecx
f01019e2:	39 f7                	cmp    %esi,%edi
f01019e4:	0f 86 d6 00 00 00    	jbe    f0101ac0 <__umoddi3+0x140>
f01019ea:	89 d0                	mov    %edx,%eax
f01019ec:	89 ca                	mov    %ecx,%edx
f01019ee:	83 c4 1c             	add    $0x1c,%esp
f01019f1:	5b                   	pop    %ebx
f01019f2:	5e                   	pop    %esi
f01019f3:	5f                   	pop    %edi
f01019f4:	5d                   	pop    %ebp
f01019f5:	c3                   	ret    
f01019f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019fd:	8d 76 00             	lea    0x0(%esi),%esi
f0101a00:	89 fd                	mov    %edi,%ebp
f0101a02:	85 ff                	test   %edi,%edi
f0101a04:	75 0b                	jne    f0101a11 <__umoddi3+0x91>
f0101a06:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a0b:	31 d2                	xor    %edx,%edx
f0101a0d:	f7 f7                	div    %edi
f0101a0f:	89 c5                	mov    %eax,%ebp
f0101a11:	89 d8                	mov    %ebx,%eax
f0101a13:	31 d2                	xor    %edx,%edx
f0101a15:	f7 f5                	div    %ebp
f0101a17:	89 f0                	mov    %esi,%eax
f0101a19:	f7 f5                	div    %ebp
f0101a1b:	89 d0                	mov    %edx,%eax
f0101a1d:	31 d2                	xor    %edx,%edx
f0101a1f:	eb 8c                	jmp    f01019ad <__umoddi3+0x2d>
f0101a21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a28:	89 e9                	mov    %ebp,%ecx
f0101a2a:	ba 20 00 00 00       	mov    $0x20,%edx
f0101a2f:	29 ea                	sub    %ebp,%edx
f0101a31:	d3 e0                	shl    %cl,%eax
f0101a33:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a37:	89 d1                	mov    %edx,%ecx
f0101a39:	89 f8                	mov    %edi,%eax
f0101a3b:	d3 e8                	shr    %cl,%eax
f0101a3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101a41:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101a45:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101a49:	09 c1                	or     %eax,%ecx
f0101a4b:	89 d8                	mov    %ebx,%eax
f0101a4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a51:	89 e9                	mov    %ebp,%ecx
f0101a53:	d3 e7                	shl    %cl,%edi
f0101a55:	89 d1                	mov    %edx,%ecx
f0101a57:	d3 e8                	shr    %cl,%eax
f0101a59:	89 e9                	mov    %ebp,%ecx
f0101a5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101a5f:	d3 e3                	shl    %cl,%ebx
f0101a61:	89 c7                	mov    %eax,%edi
f0101a63:	89 d1                	mov    %edx,%ecx
f0101a65:	89 f0                	mov    %esi,%eax
f0101a67:	d3 e8                	shr    %cl,%eax
f0101a69:	89 e9                	mov    %ebp,%ecx
f0101a6b:	89 fa                	mov    %edi,%edx
f0101a6d:	d3 e6                	shl    %cl,%esi
f0101a6f:	09 d8                	or     %ebx,%eax
f0101a71:	f7 74 24 08          	divl   0x8(%esp)
f0101a75:	89 d1                	mov    %edx,%ecx
f0101a77:	89 f3                	mov    %esi,%ebx
f0101a79:	f7 64 24 0c          	mull   0xc(%esp)
f0101a7d:	89 c6                	mov    %eax,%esi
f0101a7f:	89 d7                	mov    %edx,%edi
f0101a81:	39 d1                	cmp    %edx,%ecx
f0101a83:	72 06                	jb     f0101a8b <__umoddi3+0x10b>
f0101a85:	75 10                	jne    f0101a97 <__umoddi3+0x117>
f0101a87:	39 c3                	cmp    %eax,%ebx
f0101a89:	73 0c                	jae    f0101a97 <__umoddi3+0x117>
f0101a8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101a8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101a93:	89 d7                	mov    %edx,%edi
f0101a95:	89 c6                	mov    %eax,%esi
f0101a97:	89 ca                	mov    %ecx,%edx
f0101a99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a9e:	29 f3                	sub    %esi,%ebx
f0101aa0:	19 fa                	sbb    %edi,%edx
f0101aa2:	89 d0                	mov    %edx,%eax
f0101aa4:	d3 e0                	shl    %cl,%eax
f0101aa6:	89 e9                	mov    %ebp,%ecx
f0101aa8:	d3 eb                	shr    %cl,%ebx
f0101aaa:	d3 ea                	shr    %cl,%edx
f0101aac:	09 d8                	or     %ebx,%eax
f0101aae:	83 c4 1c             	add    $0x1c,%esp
f0101ab1:	5b                   	pop    %ebx
f0101ab2:	5e                   	pop    %esi
f0101ab3:	5f                   	pop    %edi
f0101ab4:	5d                   	pop    %ebp
f0101ab5:	c3                   	ret    
f0101ab6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101abd:	8d 76 00             	lea    0x0(%esi),%esi
f0101ac0:	29 fe                	sub    %edi,%esi
f0101ac2:	19 c3                	sbb    %eax,%ebx
f0101ac4:	89 f2                	mov    %esi,%edx
f0101ac6:	89 d9                	mov    %ebx,%ecx
f0101ac8:	e9 1d ff ff ff       	jmp    f01019ea <__umoddi3+0x6a>
