//= require mutiny/src/core
//= require chartist/dist/chartist.js

Mutiny.widgets.graph = {
  defaults: {
    low: 0,
    chartPadding: 0,
    showPoint: false,
    axisX: {
      offset: 20,
      labelInterpolationFnc: function(value, index, source){
        var yyyy = value.substr(0, 4)
        var prevValue = source[index - 1]

        if(index === 0 || prevValue.indexOf(yyyy) !== 0){
          return yyyy
        }

        return null
      },
    },
    axisY: {
      offset: 50,
    }
  },

  init: function(instigator, options){
    var data = options.data
    options.data = null
    new Chartist.Line(instigator, data, options)
  }
}
