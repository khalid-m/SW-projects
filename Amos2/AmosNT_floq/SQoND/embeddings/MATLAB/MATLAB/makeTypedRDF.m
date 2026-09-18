function [rdf]= makeTypedRDF(liter,type)
rdf = TYPEDRDFTYPE;
rdf.Literal = liter;
rdf.DataType = type;
end