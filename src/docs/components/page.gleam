import gleam/list
import sprocket/context.{type Context, provider}
import sprocket/component.{component, render}
import sprocket/html/elements.{div, ignore, raw}
import sprocket/html/attributes.{class, id}
import sprocket/hooks.{memo, reducer} as _
import sprocket/internal/utils/ordered_map.{KeyedItem}
import docs/components/header.{HeaderProps, MenuItem, header}
import docs/components/responsive_drawer.{
  ResponsiveDrawerProps, responsive_drawer,
}
import docs/components/pages/not_found.{NotFoundPageProps, not_found_page}
import docs/components/sidebar.{SidebarProps, sidebar}
import docs/components/prev_next_nav.{PrevNextNavProps, prev_next_nav}
import docs/theme.{type DarkMode, type Theme, Auto, Theme}
import docs/page_server
import docs/app_context.{type AppContext}
import docs/page_route

type Model {
  Model(mode: DarkMode)
}

type Msg {
  SetMode(mode: DarkMode)
}

fn update(_model: Model, msg: Msg) -> Model {
  case msg {
    SetMode(mode) -> Model(mode: mode)
  }
}

fn initial() -> Model {
  Model(Auto)
}

pub type PageProps {
  PageProps(app: AppContext, path: String)
}

pub fn page(ctx: Context, props: PageProps) {
  let PageProps(app, path: path) = props

  let page_name = page_route.name_from_path(path)

  let page_content = page_server.get_page(app.page_server, page_name)

  use ctx, Model(mode), dispatch <- reducer(ctx, initial(), update)

  use ctx, pages <- memo(
    ctx,
    fn() {
      page_server.list_page_routes(app.page_server)
      |> list.map(fn(page_route) { KeyedItem(page_route.name, page_route) })
      |> ordered_map.from_list()
    },
    context.OnMount,
  )

  render(
    ctx,
    div([id("app")], [
      div([], [
        provider(
          "theme",
          Theme(mode: mode, set_mode: fn(mode) { dispatch(SetMode(mode)) }),
          div([], [
            component(
              header,
              HeaderProps(menu_items: [
                MenuItem("Github", "https://github.com/bitbldr/sprocket"),
              ]),
            ),
          ]),
        ),
      ]),
      component(
        responsive_drawer,
        ResponsiveDrawerProps(
          drawer: component(sidebar, SidebarProps(pages, path)),
          content: div(
            [
              class(
                "prose dark:prose-invert prose-sm md:prose-base container mx-auto p-12",
              ),
            ],
            [
              case page_content {
                Ok(page_server.Page(_, _, html)) -> ignore(raw("div", html))
                _ -> component(not_found_page, NotFoundPageProps)
              },
              component(prev_next_nav, PrevNextNavProps(pages, page_name)),
            ],
          ),
        ),
      ),
    ]),
  )
}
