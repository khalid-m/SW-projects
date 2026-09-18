function resultToTable(rows,tableProperties,tableHeaders){
    if ( tableProperties == null || tableProperties == "" ) {
        tableProperties = "bordercolor='#000000' align='center' border='1' cellspacing='0' cellpadding='3' width='100%'";
    }
    var resultString = "\n<table "+tableProperties+">\n";
    if ( ! (tableHeaders == null || tableHeaders == "") ) {
        resultString = resultString + tableHeaders;
    }
    if(rows != null){
        resultString = resultString + resultToTableRow(rows,tableProperties);
    }
    resultString = resultString + "</table>\n";
    return resultString;
}

function resultToTableRow(rows,tableProperties) {
    var resultString = "<tbody>\n";
        for (var i = 0; i < rows.length; i++) {
            if(rows[i].constructor.toString().indexOf("function Array()") > -1){
            resultString += "<tr>\n";
            var n_columns = rows[i].length;
            for (var j = 0; j < n_columns; j++) {
                resultString += "<td>\n";
                if (rows[i][j] == null){
                    resultString += "none";
                }else if (rows[i][j].constructor.toString().indexOf("function Array()") > -1){
                    resultString += resultToTable(rows[i][j],tableProperties,null);
                }else{
                    resultString += rows[i][j];
                }
                resultString += "</td>\n";
            }
            resultString += "</tr>\n";
        }else{
        resultString += "<td>\n" + rows[i] + "</td>\n";
        }
    }
    resultString = resultString + "</tbody>\n";
    return resultString;
}

function populateOptions(rows,valueNum,selectID) {
    var selection = document.createElement("select");
    selection.id = selectID;
    selection.size = 1;
    var optionRow0 = document.createElement("option");
    optionRow0.value = '';
    optionRow0.text = 'None';
    if(document.all && !window.opera)
    {
        selection.add(optionRow0);
    }
    else
    {
        selection.add(optionRow0, null);
    }
    for (var j = 0; j < rows.length; j++) {
        var optionText = '';
        var optionValue = '';
        var optionTextAll = '';
        var optionRow = document.createElement("option");
        if(rows[j].constructor.toString().indexOf("function Array()") > -1){
        var n_rowText = rows[j].length;
        for (var i = 0; i < n_rowText; i++) {
            if (valueNum != null){
                optionValue = rows[j][valueNum];
            }
            optionText = rows[j][i];
            optionTextAll += optionText + ', ';
        }
        optionRow.value = optionValue;
        optionRow.text = optionTextAll;
        }else{
            optionRow.value = rows[j];
            optionRow.text = rows[j];
        }
        if(document.all && !window.opera)
        {
            selection.add(optionRow);
        }
        else
        {
            selection.add(optionRow, null);
        }
    }
    return selection;
}

function populateDiv(rows){
    var divResult = '<br>';
    if (rows.constructor.toString().indexOf("function Array()") > -1) { //multi results
        for (var i=0; i< rows.length; i++){
            divResult += rows[i] + '<br>';
        }
    }else{
        divResult += rows + '<br>';
    }
    return divResult
}