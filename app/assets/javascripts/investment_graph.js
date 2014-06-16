var InvestmentGraph = function(target, yAxis){
  var savedData = {}

  function keepN(array, n){
    var match = array.length / n
    return array.filter(function(e, i){
      return Math.floor(i % match) == 0
    })
  }

  function drawData(){
    var data = []
    for(var name in savedData){
      data = data.concat(savedData[name])
    }
    return data
  }

  var self = {
    add: function(name, data){
      for(var i=0; i < data.length; i++){
        data[i].name = name
      }
      savedData[name] = data
      return self
    },

    render: function(){
      var svg = dimple.newSvg(target, 900, 500)
      var chart = new dimple.chart(svg, drawData())
      chart.setBounds(-1, 0, 901, 500)
      chart.addCategoryAxis('x', 'date').addOrderRule('Date')
      chart.addMeasureAxis('y', yAxis)
      chart.addSeries('name', dimple.plot.line)
      chart.draw()
      return self
    }
  }

  return self
}
