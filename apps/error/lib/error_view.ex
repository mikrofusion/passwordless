defmodule Error.View do
  defmacro __using__(_) do
    quote do
      def render(_,  %{conn: %{assigns: %{reason: %Error{message: message}}}}) do
        # todo: may want to log stacktrace in dev mode
        %{ errors: [message] }
      end

      def render(_,  %{conn: %{assigns: %{reason: %Plug.Parsers.UnsupportedMediaTypeError{media_type: media_type}}}}) do
        # todo: additional logging?
        %{ errors: ["unsupported media type #{media_type}"] }
      end

      def render("400.json", _assigns) do
        # todo: additional logging
        %{errors: %{detail: "bad request"}}
      end

      def render("404.json", _assigns) do
        # todo: additional logging
        %{errors: %{detail: "not found"}}
      end

      def render("500.json", _assigns) do
        # todo: addional logging
        %{errors: %{detail: "internal server error"}}
      end

      def template_not_found(template, _assigns) do
        %{errors: %{detail: "template \'#{template}\' not found"}}
      end
    end
  end
end
