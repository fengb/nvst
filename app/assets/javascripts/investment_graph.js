var InvestmentGraph = function(target, data, options){
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

  function add(name, data){
    for(var i=0; i < data.length; i++){
      data[i].name = name
    }
    savedData[name] = data
  }

  function render(){
    var svg = dimple.newSvg(target, 900, 500)
    var chart = new dimple.chart(svg, drawData())
    chart.setBounds(-1, 0, 901, 500)
    chart.addCategoryAxis('x', options.xAxis)
    chart.addMeasureAxis('y', options.yAxis)
    chart.addSeries(options.series, dimple.plot.line)
    chart.draw()
  }

  for(var key in data) {
    add(key, data[key])
  }

  render()
}

d3.selectAll('[data-graph]').each(function(){
  var el = this
  var options = JSON.parse(el.dataset.graph)
  d3.json(options.url, function(error, data) {
    if (error) return console.warn(error);

    InvestmentGraph(el, data, options)
  })
})
