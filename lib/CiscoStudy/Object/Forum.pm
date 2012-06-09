package CiscoStudy::Object::Forum;
use strict;
use warnings;
use Dancer::Plugin::DBIC;

use Dancer ':syntax';

use CiscoStudy::Object::User;
use CiscoStudy::Tools;
my $t_obj = CiscoStudy::Tools->new;
my $u_obj = CiscoStudy::Object::User->new;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub get_forums {
    my ($self,$forum_id) = @_;
    
    my $search_hash = {};
    if ($forum_id) {
        $search_hash = { forum_id => $forum_id };
        
    }
    my $search = schema->resultset('Forum')->search($search_hash);
    
    my @forums;
    if ($search->count) {
        while (my $row = $search->next) {
            my $forum_id = $row->forum_id;
            my $topics = $self->get_topics($forum_id);
            my $hash = {
                forum_id => $forum_id,
                forum_title => $row->forum_title,
                topics => $topics,
            };
            push (@forums,$hash);
        }
    }
    return \@forums;
    
}
sub get_topics {
    my ($self,$id) = @_;
    my $search = schema->resultset('ForumTopic')->search({ forum_id => $id });
    my @topics;
    if ($search->count) {
        while(my $row = $search->next) {
            my $last_post_user = undef;
            my $last_post_date = undef;
            if ((defined $row->last_post_user_id) && (defined $row->last_post_date)) {
                $last_post_user = $u_obj->get_user($row->last_post_user_id);
                $last_post_date = $t_obj->date($row->last_post_date);
            }
            my $hash = {
                topic_id => $row->topic_id,
                topic_title => $row->topic_title,
                topic_desc => $row->topic_desc,
                threads => $row->threads,
                posts => $row->posts,
                last_post_user => $last_post_user,
                last_post_date => $last_post_date,
            };
            push (@topics,$hash);
        }
    }
    return \@topics;
}
sub get_topic {
    my ($self,$thread_id) = @_;
    my $row = schema->resultset('ForumTopic')->find($thread_id);
    if ($row) {
    
        my $date = $t_obj->date($row->topic_created);
        my $forum_id = $row->forum_id;
        my $forum = $self->get_forum($forum_id);
        my $hash = {
            topic_id => $thread_id,
            forum => $forum,
            topic_title => $row->topic_title,
            date => $date,
            threads => $row->threads,
        };
        return $hash;
    }
    else {
        return 0;
    }
}
sub get_forum {
    my ($self,$forum_id) = @_;
    my $row = schema->resultset('Forum')->find($forum_id);
    my $date = $t_obj->date($row->forum_created);
    my $hash = {
        forum_id => $forum_id,
        date => $date,
        forum_title => $row->forum_title,
        
    };
    return $hash;
        
}
sub count_threads {
    my ($self,$topic_id) = @_;
    
    my $count = schema->resultset('ForumThread')->search({ topic_id => $topic_id})->count;
    return $count;
}

sub get_thread {
    my ($self,$thread_id) = @_;
    
    my $search = schema->resultset('ForumThread')->find($thread_id);
    if ($search) {
        my $row = $search;
        my $id = $row->user_id;
        my $user = $u_obj->get_user($id);
        my $date = $t_obj->date($row->thread_created);
            
        my $last_post_user = undef;
        my $last_post_date = undef;
        if ((defined $row->last_post_user_id) && (defined $row->last_post_date)) {
            $last_post_user = $u_obj->get_user($row->last_post_user_id);
            $last_post_date = $t_obj->date($row->last_post_date);
        }
        my $hash = {
            thread_id => $row->thread_id,
            topic_id => $row->topic_id,
            thread_title => $row->thread_title,
            thread_posts => $row->thread_posts,
            thread_views => $row->thread_views,
            date_created => $date,
            user_id => $id,
            user =>  $user,
            last_post_user => $last_post_user,
            last_post_date => $last_post_date,
            sticky => $row->sticky,
            locked => $row->locked,
            
        };
        return $hash;
    }
    else {
        return 0;
    }
}
sub get_threads {
    my ($self,$topic_id,$page) = @_;
    
    my @threads;
    
    
    my $rows = 10;
    
    # sticky threads
    
    
    my $sticky_search = schema->resultset('ForumThread')->search(
        { topic_id => $topic_id, sticky => 1},
        { rows => 10, order_by => { -desc => 'thread_created'}}
    )->page($page);
    
    
    # regular threads
    
    my $sticky_count = $sticky_search->count;
    my $rows_regular = 10 - $sticky_count;
    my $regular_search = schema->resultset('ForumThread')->search(
        { topic_id => $topic_id, sticky => 0 },
        
        { rows => $rows_regular, order_by => { -desc => 'thread_created'}}
    )->page($page);

    if ($sticky_count) {
        while (my $row = $sticky_search->next) {
            my $id = $row->user_id;
            my $user = $u_obj->get_user($id);
            my $date = $t_obj->date($row->thread_created);
            
            my $last_post_user = undef;
            my $last_post_date = undef;
            if ((defined $row->last_post_user_id) && (defined $row->last_post_date)) {
                $last_post_user = $u_obj->get_user($row->last_post_user_id);
                $last_post_date = $t_obj->date($row->last_post_date);
            }
            my $hash = {
                thread_id => $row->thread_id,
                thread_title => $row->thread_title,
                thread_posts => $row->thread_posts,
                thread_views => $row->thread_views,
                date_created => $date,
                user_id => $id,
                user =>  $user,
                last_post_user => $last_post_user,
                last_post_date => $last_post_date,
                sticky => $row->sticky,
                locked => $row->locked,
                
                
            };
            push(@threads,$hash);
        }
    }
    if ($regular_search->count) {
        while (my $row = $regular_search->next) {
            my $id = $row->user_id;
            my $user = $u_obj->get_user($id);
            my $date = $t_obj->date($row->thread_created);
            
            my $last_post_user = undef;
            my $last_post_date = undef;
            if ((defined $row->last_post_user_id) && (defined $row->last_post_date)) {
                $last_post_user = $u_obj->get_user($row->last_post_user_id);
                $last_post_date = $t_obj->date($row->last_post_date);
            }
            my $hash = {
                thread_id => $row->thread_id,
                thread_title => $row->thread_title,
                thread_posts => $row->thread_posts,
                thread_views => $row->thread_views,
                date_created => $date,
                user_id => $id,
                user =>  $user,
                last_post_user => $last_post_user,
                last_post_date => $last_post_date,
                sticky => $row->sticky,
                locked => $row->locked,
                
                
            };
            push(@threads,$hash);
        }

    }
    return \@threads;
    
}

sub get_posts {
    my ($self,$thread_id) = @_;
    my $search = schema->resultset('ForumPost')->search({thread_id => $thread_id });
        
        
    my @posts;
    if ($search->count) {
        while(my $row = $search->next) {
            my $user_id = $row->user_id;
            my $user = $u_obj->get_user($user_id);
            my $date = $t_obj->date($row->post_created);
            my $hash = {
                post_id => $row->post_id,
                thread_id => $row->thread_id,
                date => $date,
                post => $row->post,
                user => $user,
                user_id => $user_id,
            };
            push(@posts,$hash);
        }
    }
    return \@posts;
    
}



sub get_post {
    my ($self,$post_id) = @_;
    my $post = schema->resultset('ForumPost')->find($post_id);
    
    if ($post) {
    
        my $user_id = $post->user_id;
        my $user = $u_obj->get_user($user_id);
        my $date = $t_obj->date($post->post_created);
        my $hash = {
            post_id => $post->post_id,
            thread_id => $post->thread_id,
            date => $date,
            post => $post->post,
            user => $user,
            user_id => $user_id,
        };
        return $hash;
    }
    else {
        return 0;
    }
    
    
}
sub get_flag {
    my ($self,$post_id) = @_;
    my $search = schema->resultset('ForumFlag')->search({ post_id => $post_id });
    
    if ($search->count) {
        my $flag = $search->first;
        my $flag_id = $flag->flag_id;
        my $date = $t_obj->date($flag->flag_date);
        my $user = $u_obj->get_user($flag->user_id);
        my $post = $self->get_post($flag->post_id);
    
        my $hash = {
            flag_id => $flag_id,
            date =>$date,
            user => $user,
            reason => $flag->reason,
            post => $post,
        };
        return $hash;
    }
    return 0;
}

1;
=cut
mysql> describe forum_post;
+--------------+------------------+------+-----+---------+----------------+
| Field        | Type             | Null | Key | Default | Extra          |
+--------------+------------------+------+-----+---------+----------------+
| post_id      | int(11)          | NO   | PRI | NULL    | auto_increment |
| thread_id    | int(10) unsigned | NO   |     | NULL    |                |
| date_created | int(14) unsigned | NO   |     | NULL    |                |
| post         | blob             | NO   |     | NULL    |                |
| user_id      | int(10) unsigned | NO   |     | NULL    |                |
+--------------+------------------+------+-----+---------+----------------+
5 rows in set (0.00 sec)



