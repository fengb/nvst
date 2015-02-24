//= require mutiny/src/core
//= require chartist/dist/chartist.js

Mutiny.widgets.graph = {
  init: function(instigator, options){
    var data = options.data
    options.data = null
    new Chartist.Line(instigator, data, options)
  }
}
