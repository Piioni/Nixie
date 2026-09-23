{
  userfullname,
  useremail,
  ...
}:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = userfullname;
      email = useremail;
    };
  };
}
