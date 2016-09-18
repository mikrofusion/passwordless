defmodule Error do
  @moduledoc """
  """

  defexception [:message, plug_status: 500]

  def exception([_error, param: %Ecto.Changeset{} = changeset]) do
    %Error{
      message: Ecto.Changeset.traverse_errors(changeset, &Auth.ErrorHelpers.translate_error/1),
      plug_status: 422
    }
  end

  def exception([error: error, param: param]) do
    %Error{
      message: I18n.t!("en", "#{error}.message", param: param),
      plug_status: String.to_integer(I18n.t!("en", "#{error}.status"))
    }
  end

  def exception([error: error]) do
    exception(error: error, param: nil)
  end
end

