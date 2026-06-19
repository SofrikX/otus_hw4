enum AnalyticsEvent {
  appOpen('app_open'),
  signUpStarted('sign_up_started'),
  signInSuccess('sign_in_success'),
  feedOpened('feed_opened'),
  postCreated('post_created'),
  postLiked('post_liked'),
  commentAdded('comment_added'),
  walkJoined('walk_joined'),
  authError('auth_error'),
  backendError('backend_error');

  const AnalyticsEvent(this.name);

  final String name;
}
