import amos2

print amos2.amos_connect("")
print amos2.amos_call_func("NUMBER.NUMBER.PLUS->NUMBER", 5, 8)
print amos2.amos_call_func("NUMBER.NUMBER.IOTA->INTEGER", 1, 8)

l = []
def mapper(tpl):
  l.append(tpl)
amos2.amos_map_func(mapper, "NUMBER.NUMBER.IOTA->INTEGER", 1, 8)
print l
