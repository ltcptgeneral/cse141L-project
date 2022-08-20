from re import M
import sys
try:
	from tqdm import tqdm
except:
	def tqdm(a, *args, **kwargs):
		return a

reg_map = {
	'r0': 0,
	'r1': 1,
	'r2': 2,
	'r3': 3,
	'r4': 4,
	'r5': 5,
	'r6': 6,
	'r7': 7,
	'r8': 8,
	'r9': 9,
	'r10': 10,
	'r11': 11,
	'r12': 12,
	'r13': 13,
	'r14': 14,
	'r15': 15
}

op_type = {
	'LDI': 'I',
	'PUT': 'A',
	'GET': 'A',
	'LDW': 'S',
	'STW': 'S',
	'NXT': 'S',
	'CLB': 'G',
	'ADD': 'A',
	#'SUB': 'A',
	#'ORR': 'A',
	'AND': 'A',
	'LSH': 'T',
	'PTY': 'G',
	'CHK': 'A',
	'XOR': 'A',
	'DNE': 'N',
	'JNZ': 'G',
	'JEZ': 'G',
	'JMP': 'G',
	'JAL': 'G'
}

op_codes = {
	'LDI': 0b1_0000_0000,
	'PUT': 0b0_0000_0000,
	'GET': 0b0_0001_0000,
	'LDW': 0b0_0010_0000,
	'STW': 0b0_0010_1000,
	'NXT': 0b0_0011_0000,
	'CLB': 0b0_0011_1000,
	'ADD': 0b0_0100_0000,
	#'SUB': 0b0_0101_0000,
	#'ORR': 0b0_0110_0000,
	'AND': 0b0_0111_0000,
	'LSH': 0b0_1000_0000,
	'PTY': 0b0_1000_1000,
	'CHK': 0b0_1001_0000,
	'XOR': 0b0_1010_0000,
	'DNE': 0b0_1011_1111, 
	'JNZ': 0b0_1110_0000,
	'JEZ': 0b0_1110_1000,
	'JMP': 0b0_1111_0000,
	'JAL': 0b0_1111_1000,
	'NOP': 0b0_1000_0000
}

def get_reg(type, opcode):
	if type == 'S':
		return reg_map[opcode] - 8
	elif type == 'G':
		return reg_map[opcode]
	elif type == 'A':
		return reg_map[opcode]
	elif type == 'N':
		return 0
	else:
		print('invalid opcode detected: ' + opcode)
		exit(1)

def get_immediate(operand, labels):
	if operand.startswith("#b"):
		operand = operand.strip("#b")
		return int(operand, 2)
	elif operand.startswith("#x"):
		operand = operand.strip("#x")
		return int(operand, 16)
	elif operand.startswith("#d"):
		operand = operand.strip("#d")
		return int(operand, 10)
	elif operand in labels:
		return labels[operand]
	else:
		print('invalid immediate detected: ' + operand)
		exit(1)

output = sys.argv[1]
targets = sys.argv[2:]
#out = open(output, "wb")
out = open(output, "w")
print('detected targets: ' + str(targets))
for file in targets:
	print('assembing: ' + file)
	no_comments = []
	instructions = []
	labels = {}
	index = 0
	raw_lines = []
	instructions = []
	f = open(file, 'r')
	for line in f:
		raw_lines.append(line)
	for line in tqdm(raw_lines, desc='Preprocessing', unit=' lines'):
		line = line.split('//')[0] # remove comments
		if line != '':
			line = line.replace('\t', '') # remove leading tabs
			line = line.replace('\n', '') # remove trailing newline
			if ': ' in line:
				if line.split(': ')[0] in labels:
					print('dublicate label "' + line.split(': ')[0] + '" detected')
					exit(1)
				labels[line.split(': ')[0]] = index # ': ' must be used to end a label
				no_comments.append(line.split(': ')[1])
			else:
				no_comments.append(line)
			index += 1
	index = 0
	for line in tqdm(no_comments, desc='Operand', unit=' operands'):
		line = line.split(' ')
		opcode = line[0]
		operand = line[1]
		if op_type[opcode] == "I" or op_type[opcode] == "T":
			operand = get_immediate(operand, labels)
		else:
			operand = get_reg(op_type[opcode], operand)
		instructions.append((opcode, operand))
		index += 1
	for i in tqdm(range(len(instructions), 256), desc='Paging', unit='instructions'):
		instructions.append(("NOP", 0b0_0000_0000)) # append many NOPs to fill up the 256 instruction program block
	for inst in tqdm(instructions, desc='Assembly', unit=' instructions'):
		opcode = op_codes[inst[0]]
		operand = inst[1]
		out.write(format(opcode | operand, 'b') + '\n')
		#out.write((opcode| operand).to_bytes(length=2, byteorder='big'))