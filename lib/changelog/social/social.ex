defmodule Changelog.Social do
  use ChangelogWeb, :verified_routes

  alias Changelog.Social.Client
  alias Changelog.Episode
  alias ChangelogWeb.EpisodeView

  def post(episode = %Episode{}) do
    episode = Episode.preload_all(episode)
    podcast = episode.podcast

    content = """
    #{ann_emoj()} #{ann_text(podcast)}

    #{description(episode)}

    #{link_emoj()} #{link_url(episode)} #{tags(podcast)}
    """

    token = token_for_podcast(podcast)

    case Client.create_status(token, content) do
      {:ok, %{body: body}} -> Episode.socialize_url(episode, body["url"])
      {:error, response} -> {:error, response}
    end
  end

  defp ann_emoj, do: ~w(🙌 🎉 🔥 💥 🚢 🚀 ⚡️ ✨ 🤘) |> Enum.random()

  defp ann_text(podcast) do
    case podcast.slug do
      "podcast" -> "New Changelog interview!"
      "shipit" -> "New episode of Ship It!"
      _else -> "New episode of #{podcast.name}!"
    end
  end

  defp description(episode) do
    episode |> EpisodeView.text_description(400)
  end

  defp link_emoj, do: ~w(✨ 💫 🔗 👉 🎧) |> Enum.random()

  defp link_url(episode), do: episode |> EpisodeView.share_url()

  defp tags(podcast) do
    case podcast.slug do
      "news" -> "#news #podcast"
      "gotime" -> "#golang #podcast"
      _else -> "#podcast"
    end
  end

  defp token_for_podcast(%{mastodon_token: nil}) do
    Client.default_token()
  end

  defp token_for_podcast(%{mastodon_token: token}), do: token
end
