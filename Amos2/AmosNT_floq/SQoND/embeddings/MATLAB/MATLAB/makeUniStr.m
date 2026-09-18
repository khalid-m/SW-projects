function [unistr] = makeUniStr(str,lang)
unistr = UNISTRINGTYPE;    
unistr.String = str;
unistr.LangTag = lang;
end