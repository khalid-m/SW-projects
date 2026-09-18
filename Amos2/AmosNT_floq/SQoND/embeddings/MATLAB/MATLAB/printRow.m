function []= printRow(Sid,elemNum)
res=cell(1,elemNum);
    for i = 1:elemNum
        element =  getElement(Sid,i);
        if(iscell(element))
            res{i}=element;
        elseif(islogical(element))
                if(isequal(element,false)) 
                   res{i}='FALSE';
                else
                    res{i}='TRUE';
                end
        elseif (isfloat(element)|| isinteger(element)||isreal(element))
            %disp(element);
            res{i}=element;
        elseif(ischar(element))
            %disp(element);
            res{i}=element;
        elseif(isobject(element))
            className=class(element);
            if isequal(className,'TIMEVALTYPE')
               elemStr=datestr(element.TimeVector);
            elseif isequal(className,'URITYPE')
                elemStr=strcat('<',element.UriID,'>');
            elseif isequal(className,'UNISTRINGTYPE')
                elemStr=strcat(element.String,'@',element.LangTag);
            elseif isequal(className,'TYPEDRDFTYPE')
                elemStr=strcat(element.Literal,'^^','<',element.DataType,'>');
            end
            res{i}= elemStr;
        end
    end
        disp(res);
end

		