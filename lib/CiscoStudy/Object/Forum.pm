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
    my ($self) = @_;
    
    my $search = schema->resultset('Forum')->search(undef, { order_by => { -asc => 'forum_order'}});
    
    my @forums;
    if ($search->count) {
        while (my $row = $search->next) {
            my $forum_id = $row->forum_id;
            #my $topics = $self->get_topics($forum_id);
            
            

            my $last_post_user = undef;
            my $last_post_date = undef;
            if (($row->last_post_by > 0) && ($row->last_post_date > 0)) {
                $last_post_user = $u_obj->get_user($row->last_post_by);
                $last_post_date = $t_obj->date($row->last_post_date);
            }
            


            my $hash = {
                forum_id => $forum_id,
                forum_title      => $row->forum_title,
                forum_title_safe => $t_obj->safe($row->forum_title),
                
                forum_desc => $row->forum_desc,
                forum_desc_safe => $t_obj->safe($row->forum_desc),
                
                topics => $row->topics,
                posts => $row->posts,
                last_post_date => $last_post_date,
                last_post_by  => $last_post_user,
                
                #topics => $topics,
            };
            push (@forums,$hash);
        }
    }
    return \@forums;
    
}

sub get_forum {
    my ($self,$forum_id) = @_;
    
    my $search = schema->resultset('Forum')->find($forum_id);
    
    
    if ($search) {

        my $row = $search;
        my $forum_id = $row->forum_id;
        my $topics = $self->get_topics($forum_id);
        my $hash = {
            forum_id => $forum_id,
            forum_title => $row->forum_title,
            forum_title_safe => $t_obj->safe($row->forum_title),
            topics => $topics,
            
        };
              
        return $hash;
    }
    else {
        return 0;
    }
    
    
}
sub get_topics {
    my ($self,$id) = @_;
    my $search = schema->resultset('ForumTopic')->search({ forum_id => $id },{ order_by => { -asc => 'topic_order'}});
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
                topic_title_safe => $t_obj->safe($row->topic_title),
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
            topic_title_safe => $t_obj->safe($row->topic_title),
            date => $date,
            threads => $row->threads,
        };
        return $hash;
    }
    else {
        return 0;
    }
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
            thread_title_safe => $t_obj->safe($row->thread_title),
            thread_post => $row->thread_post,
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
            my $thread_id = $row->thread_id;
            my $views = $self->get_thread_views($thread_id);
            
            my $last_post_user = undef;
            my $last_post_date = undef;
            if ((defined $row->last_post_user_id) && (defined $row->last_post_date)) {
                $last_post_user = $u_obj->get_user($row->last_post_user_id);
                $last_post_date = $t_obj->date($row->last_post_date);
            }
            my $hash = {
                thread_id => $row->thread_id,
                thread_title => $row->thread_title,
                thread_title_safe => $t_obj->safe($row->thread_title),
                thread_posts => $row->thread_posts,
                thread_views => $views,
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
            my $thread_id = $row->thread_id;
            my $views = $self->get_thread_views($thread_id);
            my $last_post_user = undef;
            my $last_post_date = undef;
            if ((defined $row->last_post_user_id) && (defined $row->last_post_date)) {
                $last_post_user = $u_obj->get_user($row->last_post_user_id);
                $last_post_date = $t_obj->date($row->last_post_date);
            }
            my $hash = {
                thread_id => $row->thread_id,
                thread_title => $row->thread_title,
                thread_title_safe => $t_obj->safe($row->thread_title),
                thread_posts => $row->thread_posts,
                thread_views => $views,
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
            
            
            my $post_edit_date;
            my $post_edit_user;
            
            if ( $row->post_edit > 0) {
                $post_edit_date = $t_obj->date($row->post_edit_date);
                $post_edit_user = $u_obj->get_user($row->post_edit_user_id);
            }
                
            
            my $hash = {
                post_id => $row->post_id,
                thread_id => $row->thread_id,
                date => $date,
                post => $row->post,
                post_safe => $t_obj->safe($row->post),
                post_edit => $row->post_edit,
                post_edit_date => $post_edit_date,
                post_edit_reason => $row->post_edit_reason,
                post_edit_user => $post_edit_user,
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

sub increase_view {
    my ($self,$thread_id) = @_;
    
    my $search = schema->resultset('ThreadViews')->search({ thread_id => $thread_id });
    
    if ($search->count) {
        my $row = $search->first;
        my $views = $row->views + 1;
        $row->update({ views => $views });
        
    }
    else {
        my $create = schema->resultset('ThreadViews')->create({ thread_id => $thread_id,views => 1 });
    }
    
}
sub get_thread_views {
    my ($self,$thread_id) = @_;
    
    my $search = schema->resultset('ThreadViews')->search({ thread_id => $thread_id});
    
    if ($search->count) {
        return $search->first->views;
    }
    else {
        return 0;
    }
    
    
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



