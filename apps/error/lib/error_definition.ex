defmodule ErrorDefinition do

  def errors do
    [
      param: [
        missing: [
          message: "missing param(s) %{param}",
          status: "422"
        ]
      ],
      invalid: [ # TODO: should return WWW-Authenticate Header on 401 responses
        login: [
          message: "unable to log in user",
          status: "401"
        ]
      ],
      resource: [
        path: [
          not: [
            found: [
              message: "resource path not found",
              status: "404"
            ]
          ]
        ]
      ],
    ]
  end

end
