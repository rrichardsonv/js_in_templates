defmodule JsInTemplatesWeb.Engine do
  @behaviour Phoenix.Template.Engine

  def compile(path, _name) do
    path
    |> read!()
    |> EEx.compile_string(engine: Phoenix.HTML.Engine, file: path, line: 1)
  end

  def read!(path) do
    path
    |> File.read!()
    |> precompile(path)
  end

  def precompile(source, path) do
    script_path =
      path
      |> Path.rootname(".html.eex")
      |> Kernel.<>(".js")

    every_script_path =
      path
      |> Path.dirname()
      |> Path.join("every.js")

    included_scripts =
      [script_path, every_script_path]
      |> Enum.filter(&File.exists?/1)
      |> Enum.map(fn p ->
        p
        |> Path.split()
        |> Enum.reverse()
        |> Enum.take(2)
        |> Enum.reverse()
        |> Enum.join("-")
      end)

    """
    #{source}
    #{Enum.map_join(included_scripts, "\n", &script_tag/1)}
    """
  end

  defp script_tag(src) do
    """
    <script defer type="text/javascript" src="<%= Routes.static_path(@conn, "/js/#{src}") %>"></script>
    """
  end
end
