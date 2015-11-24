CREATE TABLE sys_info (
  name text NOT NULL,
  value text,
  comment text,
  PRIMARY KEY (name)
);
INSERT INTO sys_info (name, value, comment) VALUES ('signup.supporter.email', '"Thanks for signing up as a Supporter member, [% name %]!"', NULL);
INSERT INTO sys_info (name, value, comment) VALUES ('signup.supporter.subject', '"Welcome as a Supporter!"', NULL);
INSERT INTO sys_info (name, value, comment) VALUES ('signup.community.email', '"Thanks for applying to form a new Community, [% name %]!\r\n\r\nWe will review your application and be in touch shortly."', NULL);
INSERT INTO sys_info (name, value, comment) VALUES ('signup.community.subject', '"We''ve received your application to form a new Community"', NULL);

