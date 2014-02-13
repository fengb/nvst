InvestmentGraph = function(){
  function Class(target, yAxis){
    this.target = target
    this.savedData = {}
    this.yAxis = yAxis
  }

  Class.prototype.add = function(data, name){
    for(var i=0; i < data.length; i++){
      data[i].name = name
    }
    this.savedData[name] = data
    this.render()
  }

  function keepN(array, n){
    var match = array.length / n
    return array.filter(function(e, i){
      return Math.floor(i % match) == 0
    })
  }

  Class.prototype.data = function(){
    var data = []
    for(var name in this.savedData){
      data = data.concat(keepN(this.savedData[name], 200))
    }
    return data
  }

  Class.prototype.render = function(){
    $(this.target + ' svg').remove()
    var svg = dimple.newSvg(this.target, 590, 400)
    var chart = new dimple.chart(svg, this.data())
    chart.setBounds(60, 30, 505, 305)
    chart.addCategoryAxis('x', 'date').addOrderRule('Date')
    chart.addMeasureAxis('y', this.yAxis)
    chart.addSeries('name', dimple.plot.line)
    chart.draw()
    return this
  }

  return Class
}()
