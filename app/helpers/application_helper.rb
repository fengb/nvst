module ApplicationHelper
  def j(jsonable)
    jsonable.to_json
  end

  def json_render(template, options)
    str = render(template, options)
    JSON.parse(str)
  end
end
