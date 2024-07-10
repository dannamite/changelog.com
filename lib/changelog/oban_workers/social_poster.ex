defmodule Changelog.ObanWorkers.SocialPoster do
  @moduledoc """
  This module defines the Oban worker for posting to social media about new episodes
  """
  use Oban.Worker

  alias Changelog.{Bsky, Episode, Repo, Social, Slack}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"episode_id" => episode_id}}) do
    episode = Episode |> Repo.get(episode_id) |> Episode.preload_all()

    post_bsky_new_episode_message(episode)
    post_social_new_episode_message(episode)
    post_slack_new_episode_message(episode)

    :ok
  end

  defp post_bsky_new_episode_message(episode), do: Bsky.post(episode)

  defp post_social_new_episode_message(episode), do: Social.post(episode)

  defp post_slack_new_episode_message(episode) do
    message = Slack.Messages.new_episode(episode)
    Slack.Client.message("#main", message)
  end

  def queue(episode = %Episode{}) do
    %{"episode_id" => episode.id} |> new() |> Oban.insert()
  end
end
