import gleam/io
import gleam/int
import gleam/string
import gleam/option.{None}
import gleam/result
import gleam/erlang/os
import gleam/erlang/process
import mist
import sprocket
import docs/router
import docs/app_context.{AppContext}
import docs/utils/logger
import docs/utils/common

pub fn main() {
  logger.configure_backend(logger.Debug)
  let secret_key_base = common.random_string(64)

  // TODO: actually validate csrf token
  let validate_csrf = fn(_csrf) { Ok(Nil) }

  let port = load_port()
  let ca = case sprocket.start(validate_csrf, None) {
    Ok(ca) -> ca
    Error(err) -> {
      io.debug(err)

      panic("Failed to start sprocket")
    }
  }

  router.stack(AppContext(secret_key_base, ca))
  |> mist.new
  |> mist.port(port)
  |> mist.start_http

  string.concat(["Listening on localhost:", int.to_string(port), " ✨"])
  |> logger.info

  process.sleep_forever()
}

fn load_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(3000)
}
