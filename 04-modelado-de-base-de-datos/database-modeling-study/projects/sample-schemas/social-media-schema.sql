-- ============================================================================
-- Social Media Platform - Complete Database Schema
-- ============================================================================
-- Description: Comprehensive social media system for users, posts, comments,
--              likes, followers, messages, and notifications.
-- Database: MySQL / PostgreSQL compatible
-- Author: Database Modeling Study
-- ============================================================================

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS comment_likes;
DROP TABLE IF EXISTS post_likes;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS post_hashtags;
DROP TABLE IF EXISTS hashtags;
DROP TABLE IF EXISTS post_media;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS followers;
DROP TABLE IF EXISTS user_blocks;
DROP TABLE IF EXISTS friendships;
DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS users;

-- ============================================================================
-- USERS (AUTHENTICATION)
-- ============================================================================

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    account_status ENUM('active', 'suspended', 'deactivated', 'deleted') DEFAULT 'active',
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (account_status)
);

-- ============================================================================
-- USER PROFILES
-- ============================================================================

CREATE TABLE user_profiles (
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    display_name VARCHAR(50),
    bio TEXT,
    profile_picture_url VARCHAR(500),
    cover_photo_url VARCHAR(500),
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other', 'prefer_not_to_say'),
    location VARCHAR(100),
    website VARCHAR(200),
    is_private BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    follower_count INT DEFAULT 0,
    following_count INT DEFAULT 0,
    post_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (follower_count >= 0),
    CHECK (following_count >= 0),
    CHECK (post_count >= 0)
);

-- ============================================================================
-- FOLLOWERS (FOLLOW RELATIONSHIPS)
-- ============================================================================

CREATE TABLE followers (
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notification_enabled BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (follower_id, following_id),
    FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (follower_id != following_id),
    INDEX idx_follower (follower_id),
    INDEX idx_following (following_id)
);

-- ============================================================================
-- FRIENDSHIPS (MUTUAL CONNECTIONS)
-- ============================================================================

CREATE TABLE friendships (
    user_id_1 INT NOT NULL,
    user_id_2 INT NOT NULL,
    status ENUM('pending', 'accepted', 'blocked') DEFAULT 'pending',
    requested_by INT NOT NULL,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    PRIMARY KEY (user_id_1, user_id_2),
    FOREIGN KEY (user_id_1) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id_2) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (requested_by) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (user_id_1 < user_id_2), -- Ensure ordered pair to prevent duplicates
    INDEX idx_status (status)
);

-- ============================================================================
-- USER BLOCKS
-- ============================================================================

CREATE TABLE user_blocks (
    blocker_id INT NOT NULL,
    blocked_id INT NOT NULL,
    blocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(200),
    PRIMARY KEY (blocker_id, blocked_id),
    FOREIGN KEY (blocker_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (blocked_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (blocker_id != blocked_id)
);

-- ============================================================================
-- POSTS
-- ============================================================================

CREATE TABLE posts (
    post_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT,
    post_type ENUM('text', 'image', 'video', 'link', 'poll') DEFAULT 'text',
    privacy ENUM('public', 'followers', 'friends', 'private') DEFAULT 'public',
    location VARCHAR(100),
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    share_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_created (user_id, created_at DESC),
    INDEX idx_created (created_at DESC),
    INDEX idx_privacy (privacy),
    CHECK (like_count >= 0),
    CHECK (comment_count >= 0),
    CHECK (share_count >= 0),
    CHECK (view_count >= 0)
);

-- ============================================================================
-- POST MEDIA (IMAGES/VIDEOS ATTACHED TO POSTS)
-- ============================================================================

CREATE TABLE post_media (
    media_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    media_type ENUM('image', 'video', 'gif') NOT NULL,
    media_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    width INT,
    height INT,
    file_size INT, -- in bytes
    duration INT, -- in seconds for videos
    media_order INT DEFAULT 1,
    alt_text VARCHAR(200),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    INDEX idx_post (post_id)
);

-- ============================================================================
-- HASHTAGS
-- ============================================================================

CREATE TABLE hashtags (
    hashtag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag VARCHAR(50) UNIQUE NOT NULL,
    use_count INT DEFAULT 0,
    trending_score DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tag (tag),
    INDEX idx_trending (trending_score DESC),
    CHECK (use_count >= 0)
);

-- ============================================================================
-- POST HASHTAGS (MANY-TO-MANY)
-- ============================================================================

CREATE TABLE post_hashtags (
    post_id BIGINT NOT NULL,
    hashtag_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, hashtag_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id) ON DELETE CASCADE,
    INDEX idx_hashtag_created (hashtag_id, created_at DESC)
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

CREATE TABLE comments (
    comment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    parent_comment_id BIGINT, -- For nested replies
    content TEXT NOT NULL,
    like_count INT DEFAULT 0,
    reply_count INT DEFAULT 0,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE,
    INDEX idx_post_created (post_id, created_at DESC),
    INDEX idx_user (user_id),
    INDEX idx_parent (parent_comment_id),
    CHECK (like_count >= 0),
    CHECK (reply_count >= 0)
);

-- ============================================================================
-- POST LIKES
-- ============================================================================

CREATE TABLE post_likes (
    post_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_liked (liked_at DESC)
);

-- ============================================================================
-- COMMENT LIKES
-- ============================================================================

CREATE TABLE comment_likes (
    comment_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comment_id, user_id),
    FOREIGN KEY (comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
);

-- ============================================================================
-- MESSAGES (DIRECT MESSAGES)
-- ============================================================================

CREATE TABLE messages (
    message_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    is_deleted_by_sender BOOLEAN DEFAULT FALSE,
    is_deleted_by_receiver BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_sender_receiver (sender_id, receiver_id, created_at DESC),
    INDEX idx_receiver_read (receiver_id, is_read),
    CHECK (sender_id != receiver_id)
);

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

CREATE TABLE notifications (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    actor_id INT, -- User who triggered the notification
    notification_type ENUM('like', 'comment', 'follow', 'mention', 'friend_request', 'message') NOT NULL,
    reference_id BIGINT, -- ID of the related post, comment, etc.
    content VARCHAR(255),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read, created_at DESC),
    INDEX idx_type (notification_type)
);

-- ============================================================================
-- INSERT SAMPLE DATA
-- ============================================================================

-- Users
INSERT INTO users (username, email, password_hash, account_status)
VALUES
    ('john_doe', 'john@example.com', '$2y$10$hashedpassword1', 'active'),
    ('jane_smith', 'jane@example.com', '$2y$10$hashedpassword2', 'active'),
    ('mike_wilson', 'mike@example.com', '$2y$10$hashedpassword3', 'active'),
    ('sarah_jones', 'sarah@example.com', '$2y$10$hashedpassword4', 'active'),
    ('alex_brown', 'alex@example.com', '$2y$10$hashedpassword5', 'active'),
    ('lisa_davis', 'lisa@example.com', '$2y$10$hashedpassword6', 'active');

-- User Profiles
INSERT INTO user_profiles (user_id, display_name, bio, location, is_verified, follower_count, following_count, post_count)
VALUES
    (1, 'John Doe', 'Software developer and tech enthusiast', 'San Francisco, CA', TRUE, 1250, 340, 87),
    (2, 'Jane Smith', 'Travel blogger | Photography lover', 'New York, NY', TRUE, 5600, 890, 456),
    (3, 'Mike Wilson', 'Fitness coach and nutrition expert', 'Los Angeles, CA', FALSE, 890, 220, 234),
    (4, 'Sarah Jones', 'Digital marketing specialist', 'Chicago, IL', FALSE, 450, 380, 156),
    (5, 'Alex Brown', 'Foodie | Restaurant reviewer', 'Austin, TX', FALSE, 780, 520, 312),
    (6, 'Lisa Davis', 'Fashion designer and stylist', 'Miami, FL', TRUE, 3200, 670, 523);

-- Followers
INSERT INTO followers (follower_id, following_id)
VALUES
    (1, 2), (1, 3), (1, 6),
    (2, 1), (2, 4), (2, 5), (2, 6),
    (3, 1), (3, 2),
    (4, 2), (4, 5), (4, 6),
    (5, 1), (5, 2), (5, 3),
    (6, 1), (6, 2), (6, 4);

-- Friendships
INSERT INTO friendships (user_id_1, user_id_2, status, requested_by, accepted_at)
VALUES
    (1, 2, 'accepted', 1, '2024-01-10 10:00:00'),
    (1, 3, 'accepted', 3, '2024-01-15 14:30:00'),
    (2, 4, 'pending', 2, NULL),
    (3, 5, 'accepted', 5, '2024-01-20 09:15:00');

-- Hashtags
INSERT INTO hashtags (tag, use_count, trending_score)
VALUES
    ('technology', 1523, 87.5),
    ('travel', 2341, 95.2),
    ('fitness', 987, 72.3),
    ('food', 1876, 88.7),
    ('fashion', 1654, 82.1),
    ('photography', 1432, 79.6),
    ('motivation', 876, 68.4),
    ('lifestyle', 1234, 74.9);

-- Posts
INSERT INTO posts (user_id, content, post_type, privacy, like_count, comment_count, created_at)
VALUES
    (1, 'Just launched my new web app! Check it out 🚀 #technology #coding', 'text', 'public', 234, 45, '2024-01-15 10:30:00'),
    (2, 'Amazing sunset in Santorini! 🌅 #travel #photography #greece', 'image', 'public', 892, 123, '2024-01-16 18:45:00'),
    (3, '5 tips for building muscle effectively 💪 #fitness #health #motivation', 'text', 'public', 156, 28, '2024-01-17 08:00:00'),
    (4, 'New blog post about social media marketing trends!', 'link', 'public', 67, 12, '2024-01-17 14:20:00'),
    (5, 'Tried the best ramen in town! 🍜 Review coming soon #food #foodie', 'image', 'public', 234, 56, '2024-01-18 12:30:00'),
    (6, 'Sneak peek of my new collection launch! ✨ #fashion #design', 'image', 'followers', 451, 89, '2024-01-18 16:00:00'),
    (1, 'Working on a new project with some amazing people!', 'text', 'public', 89, 15, '2024-01-19 09:15:00'),
    (2, 'Throwback to my trip to Japan last year 🇯🇵 #travel #throwback', 'image', 'public', 678, 92, '2024-01-19 20:00:00');

-- Post Hashtags
INSERT INTO post_hashtags (post_id, hashtag_id)
VALUES
    (1, 1),
    (2, 2), (2, 6),
    (3, 3), (3, 7),
    (5, 4),
    (6, 5),
    (8, 2);

-- Post Media
INSERT INTO post_media (post_id, media_type, media_url, thumbnail_url, width, height, media_order)
VALUES
    (2, 'image', 'https://example.com/media/sunset1.jpg', 'https://example.com/media/sunset1_thumb.jpg', 1920, 1080, 1),
    (5, 'image', 'https://example.com/media/ramen1.jpg', 'https://example.com/media/ramen1_thumb.jpg', 1080, 1080, 1),
    (6, 'image', 'https://example.com/media/fashion1.jpg', 'https://example.com/media/fashion1_thumb.jpg', 1080, 1350, 1),
    (8, 'image', 'https://example.com/media/japan1.jpg', 'https://example.com/media/japan1_thumb.jpg', 1920, 1080, 1);

-- Comments
INSERT INTO comments (post_id, user_id, content, like_count, created_at)
VALUES
    (1, 2, 'Congratulations! Looks amazing!', 12, '2024-01-15 11:00:00'),
    (1, 3, 'Great work! Will definitely try it out.', 8, '2024-01-15 12:30:00'),
    (2, 1, 'Stunning photo! 😍', 34, '2024-01-16 19:00:00'),
    (2, 4, 'I was there last summer! Beautiful place.', 18, '2024-01-16 20:15:00'),
    (3, 5, 'Thanks for sharing! Very helpful tips.', 6, '2024-01-17 09:30:00'),
    (5, 2, 'That looks delicious! What restaurant?', 8, '2024-01-18 13:00:00'),
    (6, 4, 'Can''t wait to see the full collection!', 23, '2024-01-18 17:30:00');

-- Nested comments (replies)
INSERT INTO comments (post_id, user_id, parent_comment_id, content, like_count, created_at)
VALUES
    (2, 2, 4, 'Me too! Such a magical place.', 5, '2024-01-16 21:00:00'),
    (5, 5, 6, 'It''s called Ramen House on 5th Street!', 3, '2024-01-18 14:00:00');

-- Post Likes
INSERT INTO post_likes (post_id, user_id, liked_at)
VALUES
    (1, 2, '2024-01-15 10:35:00'),
    (1, 3, '2024-01-15 11:00:00'),
    (2, 1, '2024-01-16 18:50:00'),
    (2, 3, '2024-01-16 19:30:00'),
    (2, 4, '2024-01-16 20:00:00'),
    (3, 1, '2024-01-17 08:15:00'),
    (3, 5, '2024-01-17 09:00:00'),
    (5, 2, '2024-01-18 12:45:00'),
    (6, 1, '2024-01-18 16:15:00'),
    (6, 2, '2024-01-18 17:00:00');

-- Comment Likes
INSERT INTO comment_likes (comment_id, user_id)
VALUES
    (1, 1), (1, 3),
    (3, 2), (3, 4), (3, 5),
    (4, 1), (4, 2);

-- Messages
INSERT INTO messages (sender_id, receiver_id, content, is_read, read_at, created_at)
VALUES
    (1, 2, 'Hey! Thanks for the comment on my post!', TRUE, '2024-01-15 12:00:00', '2024-01-15 11:30:00'),
    (2, 1, 'You''re welcome! The app looks really cool.', TRUE, '2024-01-15 13:00:00', '2024-01-15 12:30:00'),
    (3, 1, 'Do you have time for a call next week?', FALSE, NULL, '2024-01-17 10:00:00'),
    (5, 2, 'Love your travel photos! Any tips for Santorini?', TRUE, '2024-01-17 15:00:00', '2024-01-17 14:30:00');

-- Notifications
INSERT INTO notifications (user_id, actor_id, notification_type, reference_id, content, is_read, created_at)
VALUES
    (1, 2, 'like', 1, 'jane_smith liked your post', TRUE, '2024-01-15 10:35:00'),
    (1, 2, 'comment', 1, 'jane_smith commented on your post', TRUE, '2024-01-15 11:00:00'),
    (1, 3, 'follow', NULL, 'mike_wilson started following you', TRUE, '2024-01-15 14:00:00'),
    (2, 1, 'like', 2, 'john_doe liked your post', FALSE, '2024-01-16 18:50:00'),
    (2, 5, 'message', NULL, 'alex_brown sent you a message', TRUE, '2024-01-17 14:30:00'),
    (6, 1, 'like', 6, 'john_doe liked your post', FALSE, '2024-01-18 16:15:00');

-- ============================================================================
-- USEFUL QUERIES AND VIEWS
-- ============================================================================

-- View: User Feed (posts from followed users)
CREATE OR REPLACE VIEW vw_user_feed AS
SELECT 
    p.post_id,
    p.user_id,
    u.username,
    up.display_name,
    up.profile_picture_url,
    p.content,
    p.post_type,
    p.like_count,
    p.comment_count,
    p.created_at,
    GROUP_CONCAT(DISTINCT h.tag SEPARATOR ', ') AS hashtags
FROM posts p
JOIN users u ON p.user_id = u.user_id
JOIN user_profiles up ON u.user_id = up.user_id
LEFT JOIN post_hashtags ph ON p.post_id = ph.post_id
LEFT JOIN hashtags h ON ph.hashtag_id = h.hashtag_id
WHERE p.privacy IN ('public', 'followers')
GROUP BY p.post_id, p.user_id, u.username, up.display_name, up.profile_picture_url, 
         p.content, p.post_type, p.like_count, p.comment_count, p.created_at
ORDER BY p.created_at DESC;

-- View: User Activity Summary
CREATE OR REPLACE VIEW vw_user_activity AS
SELECT 
    u.user_id,
    u.username,
    up.display_name,
    up.follower_count,
    up.following_count,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COALESCE(SUM(p.like_count), 0) AS total_likes_received,
    COALESCE(SUM(p.comment_count), 0) AS total_comments_received,
    COUNT(DISTINCT pl.post_id) AS posts_liked,
    COUNT(DISTINCT c.comment_id) AS comments_made
FROM users u
JOIN user_profiles up ON u.user_id = up.user_id
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN post_likes pl ON u.user_id = pl.user_id
LEFT JOIN comments c ON u.user_id = c.user_id
WHERE u.account_status = 'active'
GROUP BY u.user_id, u.username, up.display_name, up.follower_count, up.following_count;

-- View: Trending Hashtags
CREATE OR REPLACE VIEW vw_trending_hashtags AS
SELECT 
    h.hashtag_id,
    h.tag,
    h.use_count,
    COUNT(DISTINCT ph.post_id) AS recent_posts,
    h.trending_score
FROM hashtags h
LEFT JOIN post_hashtags ph ON h.hashtag_id = ph.hashtag_id 
    AND ph.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY h.hashtag_id, h.tag, h.use_count, h.trending_score
ORDER BY h.trending_score DESC, recent_posts DESC
LIMIT 20;

-- View: Unread Messages Count
CREATE OR REPLACE VIEW vw_unread_messages AS
SELECT 
    receiver_id AS user_id,
    sender_id,
    u.username AS sender_username,
    up.display_name AS sender_name,
    COUNT(*) AS unread_count,
    MAX(m.created_at) AS last_message_at
FROM messages m
JOIN users u ON m.sender_id = u.user_id
JOIN user_profiles up ON u.user_id = up.user_id
WHERE m.is_read = FALSE AND m.is_deleted_by_receiver = FALSE
GROUP BY receiver_id, sender_id, u.username, up.display_name
ORDER BY last_message_at DESC;

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- Procedure: Create a post with hashtags
DELIMITER $$

CREATE PROCEDURE sp_create_post(
    IN p_user_id INT,
    IN p_content TEXT,
    IN p_post_type VARCHAR(20),
    IN p_privacy VARCHAR(20),
    IN p_hashtags TEXT  -- Comma-separated hashtags
)
BEGIN
    DECLARE v_post_id BIGINT;
    DECLARE v_hashtag VARCHAR(50);
    DECLARE v_hashtag_id INT;
    DECLARE v_pos INT;
    DECLARE v_hashtag_list TEXT;
    
    -- Insert the post
    INSERT INTO posts (user_id, content, post_type, privacy)
    VALUES (p_user_id, p_content, p_post_type, p_privacy);
    
    SET v_post_id = LAST_INSERT_ID();
    
    -- Update user's post count
    UPDATE user_profiles SET post_count = post_count + 1 WHERE user_id = p_user_id;
    
    -- Process hashtags if provided
    IF p_hashtags IS NOT NULL AND p_hashtags != '' THEN
        SET v_hashtag_list = CONCAT(p_hashtags, ',');
        
        WHILE CHAR_LENGTH(v_hashtag_list) > 0 DO
            SET v_pos = LOCATE(',', v_hashtag_list);
            SET v_hashtag = TRIM(SUBSTRING(v_hashtag_list, 1, v_pos - 1));
            SET v_hashtag_list = SUBSTRING(v_hashtag_list, v_pos + 1);
            
            IF v_hashtag != '' THEN
                -- Get or create hashtag
                SELECT hashtag_id INTO v_hashtag_id FROM hashtags WHERE tag = v_hashtag;
                
                IF v_hashtag_id IS NULL THEN
                    INSERT INTO hashtags (tag, use_count) VALUES (v_hashtag, 0);
                    SET v_hashtag_id = LAST_INSERT_ID();
                END IF;
                
                -- Link hashtag to post
                INSERT IGNORE INTO post_hashtags (post_id, hashtag_id) VALUES (v_post_id, v_hashtag_id);
                
                -- Update hashtag use count
                UPDATE hashtags SET use_count = use_count + 1, last_used_at = NOW() 
                WHERE hashtag_id = v_hashtag_id;
            END IF;
        END WHILE;
    END IF;
    
    SELECT v_post_id AS post_id;
END$$

DELIMITER ;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Update follower counts when following
DELIMITER $$

CREATE TRIGGER tr_after_follow_insert
AFTER INSERT ON followers
FOR EACH ROW
BEGIN
    UPDATE user_profiles SET following_count = following_count + 1 
    WHERE user_id = NEW.follower_id;
    
    UPDATE user_profiles SET follower_count = follower_count + 1 
    WHERE user_id = NEW.following_id;
    
    -- Create notification
    INSERT INTO notifications (user_id, actor_id, notification_type, content)
    VALUES (NEW.following_id, NEW.follower_id, 'follow', 
            CONCAT((SELECT username FROM users WHERE user_id = NEW.follower_id), ' started following you'));
END$$

DELIMITER ;

-- Trigger: Update like count when post is liked
DELIMITER $$

CREATE TRIGGER tr_after_post_like_insert
AFTER INSERT ON post_likes
FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
    
    -- Create notification
    INSERT INTO notifications (user_id, actor_id, notification_type, reference_id, content)
    SELECT p.user_id, NEW.user_id, 'like', NEW.post_id,
           CONCAT((SELECT username FROM users WHERE user_id = NEW.user_id), ' liked your post')
    FROM posts p WHERE p.post_id = NEW.post_id;
END$$

DELIMITER ;

-- Trigger: Update comment count when comment is added
DELIMITER $$

CREATE TRIGGER tr_after_comment_insert
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    UPDATE posts SET comment_count = comment_count + 1 WHERE post_id = NEW.post_id;
    
    -- Update reply count for parent comment if exists
    IF NEW.parent_comment_id IS NOT NULL THEN
        UPDATE comments SET reply_count = reply_count + 1 
        WHERE comment_id = NEW.parent_comment_id;
    END IF;
    
    -- Create notification
    INSERT INTO notifications (user_id, actor_id, notification_type, reference_id, content)
    SELECT p.user_id, NEW.user_id, 'comment', NEW.post_id,
           CONCAT((SELECT username FROM users WHERE user_id = NEW.user_id), ' commented on your post')
    FROM posts p WHERE p.post_id = NEW.post_id AND p.user_id != NEW.user_id;
END$$

DELIMITER ;

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Additional indexes for common queries
CREATE INDEX idx_posts_user_privacy ON posts(user_id, privacy, created_at DESC);
CREATE INDEX idx_comments_post_parent ON comments(post_id, parent_comment_id);
CREATE INDEX idx_messages_conversation ON messages(
    LEAST(sender_id, receiver_id), 
    GREATEST(sender_id, receiver_id), 
    created_at DESC
);

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
