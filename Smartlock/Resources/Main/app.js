var setInputById = function(id,text){
    var ele = document.getElementById(id);
    if(null == ele)
    {
        return 11;
    }
    ele.setAttribute('value', text);
    return 22;
}