package CiscoStudy::Routes::Forum;

use strict;
use warnings;
use Dancer ':syntax';

use CiscoStudy::Object::Forum;
use Dancer::Plugin::DBIC;
use HTML::StripTags qw(strip_tags);


my $f_obj = CiscoStudy::Object::Forum->new;




get '/forums' => sub {
    
    var forums => $f_obj->get_forums;
    
    template 'Forum/forum.tt';
    

};
get '/forums/*' => sub {
    my ($forum_id) = splat;
    var forums => $f_obj->get_forums($forum_id);
    template 'Forum/forum.tt';
};

get '/forums/topic/*/*' => sub {
    
    my ($topic,undef) = splat;
    
    my $page = 1;
    
    if ($topic =~ /\d+/) {
        
        session current_topic => $topic;
        
        if (my $threads = $f_obj->get_threads($topic,$page)) {
            use POSIX;
            my $count = $f_obj->count_threads($topic);
            var pages => ceil ($count/10);
            
            var threads => $threads;
            var topic => $f_obj->get_topic($topic);
            var page => $page;
            template 'Forum/threads.tt';
        }
        else {
            var error => "no such topic";
            template 'error.tt';
        }
    
    }
    else {
        var error => "no such topic";
        template 'error.tt';
    }

};


# with a page number
get '/forums/topic/*/*/*' => sub {
    
    my ($topic,undef,$page) = splat;
    
    if ($topic =~ /\d+/) {
        
        session current_topic => $topic;
        
        if (my $threads = $f_obj->get_threads($topic,$page)) {
            
            use POSIX;
            
            my $count = $f_obj->count_threads($topic);
            var pages => ceil ($count/10);
            var threads => $threads;
            var topic => $f_obj->get_topic($topic);
            var page => $page;
            template 'Forum/threads.tt';
            
        }
        else {
            var error => "no such topic";
            template 'error.tt';
        }
    
    }
    else {
        var error => "no such topic";
        template 'error.tt';
    }

};

get '/forums/thread/*/*' => sub {
    my ($thread_id,undef) = splat;
    if ($thread_id =~ /\d+/) {
        if (my $thread = $f_obj->get_thread($thread_id)) {
            my $topic_id = $thread->{'topic_id'};
            var topic => $f_obj->get_topic($topic_id);
            var thread => $thread;
            var posts => $f_obj->get_posts($thread_id);
            session current_thread => $thread_id;
            var thread_id => $thread_id;
            template 'Forum/posts.tt';
        }
        else {
            var error => "Thread does not exist";
            template 'error.tt';
        }
    }
    else {
        var error => "Invalid thread id";
        template 'error.tt';
    }
    
    
};

get '/c/forums/reply/*' => sub {
    
    my ($thread_id) = splat;
    session thread_reply => $thread_id;
    
    template 'Forum/reply.tt';
};
post '/c/forums/reply/*' => sub {
    my ($thread_id) = splat;
    if ($thread_id == session('current_thread')) {
        
        my $post = param 'post';
        $post = strip_tags($post);
        
        my $date = time;
        my $user_id = session 'user_id';
 
        my $insert = schema->resultset('ForumPost')->create({
            thread_id => $thread_id,
            post_created => $date,
            post => $post,
            user_id => $user_id,
        });
        if ($insert->id) {
            redirect '/forums/thread/'. $thread_id .'/-';
        }
        else {
            template 'error.tt';
        }

        
    }
    else {
        template 'permission-denied.tt';
    }
};
get '/c/forums/flag/*' => sub {
    my ($post_id) = splat;
    if ($post_id =~ /\d+/) {
        
        if (my $flag = $f_obj->get_flag($post_id)) {
            
            var error => 'This post has already been flagged';
            template 'error.tt';
        }
        else {
        
            if (my $post = $f_obj->get_post($post_id)) {
        
                if (session('current_thread') == $post->{thread_id}) {
        
                    var post => $post;
                    session flag_post_id => $post_id;
        
        
                    template 'Forum/flag.tt';
                }
                else {
                    var error => 'Post ID is not in current thread';
                    template 'error.tt';
                
                }
            }
            else {
                var error => 'Invalid Post ID';
                template 'error.tt';
            }
        }

    }
      
        
};
post '/c/forums/flag/*' => sub {
    my ($post_id) = splat;
    if ($post_id =~ /\d+/) {
        if ($post_id == session('flag_post_id')) {
            
            my $reason = param 'reason';
            my $comment = param 'comment';
            $comment = strip_tags($comment);
            my $user_id = session('user_id');
            my $date = time;
            my $create = schema->resultset('ForumFlag')->create({
                post_id => $post_id,
                reason => $reason,
                comment => $comment,
                user_id => $user_id,
                flag_date => $date,
            });
            if ($create->id) {
                var success => $create->id;
                template 'Forum/flag.tt';
            }
            
        }
        else {
            var error => "Post ID mismatch";
            template 'error.tt';
        }
    }
    else {
        var error => "Post ID mismatch";
        template 'error.tt';  
    }
    
    
};
get '/c/forums/new-topic' => sub {
    if (session('admin')) {
        
    
        var forums => $f_obj->get_forums;
        template 'Forum/new-topic.tt';
    }
    else {
        template 'permission-denied.tt';
    }
    
};
post '/c/forums/new-topic' => sub {
    if (session('admin')) {
        my $topic = param 'newtopic';
        $topic = strip_tags($topic);
        my $desc = param 'newtopicdesc';
        $desc = strip_tags($desc);
        my $forum_id = param 'forum';
    
        my $search = schema->resultset('ForumTopic')->search({ topic_title => $topic });
        if ($search->count) {
            var error => "Topic already exists";
            var forums => $f_obj->get_forums;
        }
        else {
            my $date = time;
            my $create = schema->resultset('ForumTopic')->create({
                forum_id => $forum_id,
                topic_title => $topic,
                topic_desc => $desc,
                topic_created => $date,
            });
            if ($create->id) {
                var success => 1;
            }
        }
        template 'Forum/new-topic.tt';
    }
    else {
        template 'permission-denied.tt';
    }
    
};
get '/c/forums/new-thread' => sub {
    my $thread = session('current_topic');
    
  
    template 'Forum/new-thread.tt';

};
post '/c/forums/new-thread' => sub {
    
    if (session('current_topic')) {
        
        my $topic_id = session('current_topic');
        my $title = param 'title';
        $title = strip_tags($title);
        my $post = param 'post';
        $post = strip_tags($post);
        my $date = time;
        my $user_id = session('user_id');
        
        
        my $sticky = 0;
        my $locked = 0;

        
        if (session('moderator')) {
            $sticky = param 'sticky';
            $locked = param 'locked';
            
            $sticky = defined($sticky) ? 1 : 0;
            $locked = defined($locked) ? 1 : 0;
        }
        
        my $insert = schema->resultset('ForumThread')->create({
            topic_id => $topic_id,
            thread_title => $title,
            thread_created => $date,
            user_id => $user_id,
            sticky => $sticky,
            locked => $locked,
        });
        if ($insert->id) {
            my $id = $insert->id;
            my $newpost = schema->resultset('ForumPost')->create({
                thread_id => $id,
                post_created => $date,
                post => $post,
                user_id => $user_id,
            });
            if ($newpost->id) {
                var success => 1;
                session current_thread => $id;
                redirect '/forums/thread/'. $id .'/'. $title;
            }
            else {
                var error => "error inserting new post";
                template 'error.tt';
            }
        }
        else {
            var error => "error inserting new thread";
            template 'error.tt';
        }
        
    }
    else {
        var error => "um.. no topic id?";
        template 'error.tt';
    }
};
get '/c/forums/new-forum' => sub {
    if (session('admin')) {
        
        template 'Forum/new-forum.tt';
    }
    else {
        template 'permission-denied.tt';
    }
    
};
post '/c/forums/new-forum' => sub {
    if (session('admin')) {
        
        my $forum = param 'newforum';
        if (length $forum) {
            $forum = strip_tags($forum);
            my $date = time;
            my $create = schema->resultset('Forum')->create({ forum_created => $date, forum_title => $forum});
            if ($create->id) {
                var success => 1;
                template 'Forum/new-forum.tt';
            }
            else {
                var error => "Db error!";
                template 'error.tt';
            }
        }
        else {
            var error "Invalid forum name";
            template 'Forum/new-forum.tt';
        }
        
    }
    else {
        template 'permission-denied.tt';
    }
};
    
get '/register' => sub {
    use DateTime::TimeZone;
	my @timezones = DateTime::TimeZone->all_names;
	var timezones => \@timezones;
    template 'register.tt';
    
};

post '/register' => sub {
    my $username = param 'username';
    my $password1 = param 'password1';
    my $password2 = param 'password2';
    my $timezone = param 'timezone';
    
    
    my @errors;
    
    if ($username =~ /\w{3,16}/) {
        
        my $search = schema->resultset('User')->search({ username => $username })->count;
        
        if ($search == 0) {
            
            var username => $username;
        
            if (length $password1 > 6) {
            
                if ($password1 eq $password2) {
                    var password1 => $password1;
                    var password2 => $password2;
                    var timezone => $timezone;
                
                    use Crypt::PasswdMD5;
                    my $hash = unix_md5_crypt($password1);
                    my $date = time;
                
                
                    my $create = schema->resultset('User')->create({
                        username => $username,
                        date_joined => $date,
                        password => $hash,
                        role => "member",
                    });
                    if ($create->id) {
                        
                        session authenticated => 1;
                        session username      => $username;
                        session user_id       => $create->id;
                        session role          => "member";
                        session timezone	  => $timezone;
                        
                        redirect '/c/profile';
                    }
                }
                else {
                    push (@errors,"Passwords do not match");
                    
                }

            }
            else {
                push(@errors,"Password should be longer that 6 characters");
            }
            
        }
        else {
            push(@errors,"Username already exists");
        }
    }
    else {
        push(@errors,"Invalid username");
        
    }
    var errors => \@errors;
        use DateTime::TimeZone;
	my @timezones = DateTime::TimeZone->all_names;
	var timezones => \@timezones;
    template 'register.tt';
};

1;

