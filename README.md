# How it works 🕵️‍♂️

Dynamically build entry points in webpack config (`../templates/foo/bar.js` -> `foo-bar.js`)
```js
const globViewEntries = () => {
  return glob.sync('../lib/js_in_templates_web/templates/**/*.js').reduce((agg, path) => {
    const entryKey = path.replace('.js', '')
                         .split('/')
                         .slice(-2)
                         .join('-');

    return { ...agg, [entryKey]: [p] };
  }, {})
}
/*
Example output:
{
  'foo-index': ['../lib/js_in_templates_web/templates/foo/index.js'],
  'foo-show': ['../lib/js_in_templates_web/templates/foo/show.js']
}
*/
```


Set aliases for path resolution in webpack config
```js
{
// ...
  resolve: {
    extensions: [".js", ".ts"],
    alias: {
      '@lib': path.resolve(__dirname, "js/lib")
    },
    // ...
  },
// ...
}
```

Add shared functionality within an aliased directory
```js
// in assets/js/lib/testy.js

export function testy(...args) {
  console.log(`
  -----------------
  ${args.join('\n')}
  -----------------
  `)

  return args.length
}
```

Add scripts with same name as the template they're included in (note: can also use `every.js` for all pages in a view) using shared functionality imported from aliased directory
```js
import {testy} from '@lib/testy';

testy('In page index.js')
```


Stiching it all together, pre-compilation the Template Engine checks if there's a script with the same name as the template its working on (and/or `every.js`) and injects it if present
```elixir
defmodule JsInTemplatesWeb.Engine do
  @behaviour Phoenix.Template.Engine

  # When there's a template...
  def compile(path, _name) do
    path
    |> read!()
    |> EEx.compile_string(engine: Phoenix.HTML.Engine, file: path, line: 1)
  end

  # Get the text from it...
  def read!(path) do
    path
    |> File.read!()
    |> precompile(path)
  end

  def precompile(source, path) do
    # Create the script path for the template...
    script_path =
      path
      |> Path.rootname(".html.eex")
      |> Kernel.<>(".js")

    # Create the "every" script path...
    every_script_path =
      path
      |> Path.dirname()
      |> Path.join("every.js")

    # Filter out the scripts that don't exist by path...
    # And create the url path by convention...
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

    # Append those scripts which exist to the bottom of the template...
    """
    #{source}
    #{Enum.map_join(included_scripts, "\n", &script_tag/1)}
    """
  end

  # Because this is precompile we can leave path resolution to phoenix.
  defp script_tag(src) do
    """
    <script defer type="text/javascript" src="<%= Routes.static_path(@conn, "/js/#{src}") %>"></script>
    """
  end
end
```
