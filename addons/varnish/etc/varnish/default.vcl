#
# AWS Elastic Beanstalk Nginx/PHP-FPM Configuration
#
# @author    James Leckenby <me@jleck.co.uk>
# @link      http://jleck.co.uk
# @copyright 2013 James Leckenby
# @license   MIT License
# @version   1.0
#

backend default {
    .host = "127.0.0.1";
    .port = "8080";
}
sub vcl_recv {
    if (req.url ~ "^/_hostmanager") {
        return(pass);
    }
    unset req.http.Cookie;
    return (lookup); 
}
sub vcl_fetch {
    if (beresp.http.Set-Cookie) {
        set beresp.ttl = 5d;
        return (deliver);
    }
}