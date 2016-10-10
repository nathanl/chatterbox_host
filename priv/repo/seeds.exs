# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ChatterboxHost.Repo.insert!(%ChatterboxHost.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias ChatterboxHost.{Repo,User,Tag}

[
  %{name: "Normal McBasic", email: "normal@example.com", password: "iliketoast"},
  %{name: "Friendly von Supportenstien", email: "friendly@example.com", password: "iliketoast", cs_rep: true},
] |> Enum.each(fn (attrs) ->
  User.changeset(%User{}, attrs) |> Repo.insert!
end)

["bug", "complaint", "product_question"]
|> Enum.each(fn (tag_name) ->
  %Tag{name: tag_name} |> Repo.insert!
end)
