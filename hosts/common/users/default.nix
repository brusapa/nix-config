{ ... }:
{
  
  users = {
    # This is the default group for users
    groups.users.gid = 100;

    #mutableUsers = false;

    # Group for download related tasks
    groups.downloads.gid = 2001;

    # Group for multimedia related tasks (Jellfyfin, Plex, etc.)
    groups.multimedia.gid = 2002;
  };
}