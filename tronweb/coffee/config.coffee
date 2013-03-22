
# Configs


class window.NamespaceList extends Backbone.Model

    url: "/"


class window.Config extends Backbone.Model

    url: =>
        "/config?name=" + @get('name')


class NamespaceListEntryView extends Backbone.View

    tagName: "tr"

    template: _.template '
        <td>
            <a href="#config/<%= name %>"><%= name %></a>
        </td>'

    render: ->
        @$el.html @template(name: @model)
        @


class window.NamespaceListView extends Backbone.View

    initialize: (options) =>
        @listenTo(@model, "change", @render)

    tagName: "div"

    className: "span8"

    template: _.template '
        <h1>Configuration Namespaces</h1>
        <table class="table table-hover">
        </table>'

    render: =>
        @$el.html @template()
        entry = (name) -> new NamespaceListEntryView(model: name).render().el
        @$('table').append(entry(name) for name in @model.get('namespaces'))
        @


class window.ConfigView extends Backbone.View

    initialize: (options) =>
        @listenTo(@model, "change", @render)

    tagName: "div"

    className: "span12"

    template: _.template '
        <h1>Config: <%= name %></h1>
        <form>
            <textarea><%= config %></textarea>
        </form>'

    breadcrumb: -> [
            {url: "#configs", name: "Configs"},
            {url: "", name: @model.get('name')},
        ]

    render: =>
        @$el.html @template(@model.attributes)
        breadcrumbView.render @breadcrumb()
        CodeMirror.fromTextArea(@$('textarea').get(0), readOnly: true)
        @
