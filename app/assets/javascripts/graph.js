var Graph = function(target, data, options){
  var savedData = {}

  function drawData(){
    var drawData = []
    for(var name in data){
      var array = data[name]
      for(var i=0; i < array.length; i++) {
        array[i].name = name
        drawData.push(array[i])
      }
    }
    return drawData
  }

  var svg = dimple.newSvg(target, 900, 500)
  var chart = new dimple.chart(svg, drawData())
  chart.setBounds(-1, 0, 901, 500)
  chart.addCategoryAxis('x', options.xAxis)
  chart.addMeasureAxis('y', options.yAxis)
  chart.addSeries(options.series, dimple.plot.line)
  chart.draw()
}

d3.selectAll('[data-graph]').each(function(){
  var el = this
  var options = JSON.parse(el.dataset.graph)
  d3.json(options.url, function(error, data) {
    if (error) return console.warn(error);

    Graph(el, data, options)
  })
})
