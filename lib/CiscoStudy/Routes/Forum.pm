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
        
        var threads => $f_obj->get_threads($topic);
        var topic => $f_obj->get_topic($topic);
        
        
        
    }
    template 'Forum/threads.tt';
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
        
        session flag_post_id => $post_id;
        
        var post => $f_obj->get_post($post_id);
        
        
        
    }
    template 'Forum/flag.tt';
};

1;

