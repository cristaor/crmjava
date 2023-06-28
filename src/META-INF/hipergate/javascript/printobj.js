// Print an Object as a String
// Usage:
// var str = new PrintObject().walk(myobject);

function PrintObject() {
  this.a='';
  this.walk=function(o) {
    if(o.constructor==Array)
           this.a+='[';
    if(o.constructor==Object)
        this.a+='{';
    for (var i in o){
        if(o.constructor!=Array)
            this.a+=i+':';
        if(o[i].constructor==Object){
               this.walk(o[i]);
        } else if(o[i].constructor==Array){
            this.walk(o[i]);
        } else if(o[i].constructor==String){
            this.a+='"'+o[i]+'",';
        } else{
            this.a+=o[i]+',';
        }
    } // next
    if(o.constructor==Object)
        this.a+='},';
    if(o.constructor==Array)
        this.a+='],';
    return this.a.substr(0,this.a.length-1).split(',}').join('}').split(',]').join(']');
  } // fi
}