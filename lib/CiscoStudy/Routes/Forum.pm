package CiscoStudy::Routes::Forum;

use strict;
use warnings;
use Dancer ':syntax';

use CiscoStudy::Object::Forum;
use Dancer::Plugin::DBIC;


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
    
    if ($topic =~ /\d+/) {
        
        session current_topic => $topic;
        
        if (my $threads = $f_obj->get_threads($topic)) {
            
            var threads => $threads;
            var topic => $f_obj->get_topic($topic);
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
    my ($thread,undef) = splat;
    if ($thread =~ /\d+/) {
        var posts => $f_obj->get_posts($thread);
        session current_thread => $thread;
        var thread_id => $thread;
    }
    template 'Forum/posts.tt';
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
        my $desc = param 'newtopicdesc';
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
        my $post = param 'post';
        my $date = time;
        my $user_id = session('user_id');
        
        my $insert = schema->resultset('ForumThread')->create({
            topic_id => $topic_id,
            thread_title => $title,
            thread_created => $date,
            user_id => $user_id,
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
    

1;

