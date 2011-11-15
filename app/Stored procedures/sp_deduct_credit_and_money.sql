/*Usage: 
1 create this stored procedure in your database
2 Usage in MySQL: mysql> call sp_deduct_credit_and_money ('test','test',1,0,10.00)
3 Usage in Rails: ActiveRecord::Base.connection.execute("call sp_deduct_credit_and_money('#{title}','#{content}',#{id},#{credit},#{money})") @question_controller.rb
*/
/* Drop if Exists */
DROP PROCEDURE IF EXISTS sp_deduct_credit_and_money

/* Crete Stored Procedure*/
DELIMITER //
CREATE PROCEDURE sp_deduct_credit_and_money (
	in uuid bigint,
	in user_id bigint,
	in title varchar(100),
	in content text,
	in deduct_reputation int,
	in deduct_credit DECIMAL(8,2),
	in is_community boolean)
BEGIN
IF  is_community THEN
	START TRANSACTION;
	INSERT INTO questions (id, content, created_at, title, updated_at, user_id) 
	VALUES (uuid, content, NOW(), title, NOW(), user_id);
	COMMIT;
ELSE IF deduct_reputation > 0 AND deduct_credit =0.00 THEN
	START TRANSACTION;
 	/* Create a new question */
	INSERT INTO questions (id, content, created_at, reputation, title, updated_at, user_id) VALUES (uuid, content, NOW(), deduct_reputation, title, NOW(), user_id);

	/* update user info*/
	UPDATE users
   		SET questions_count = COALESCE(questions_count, 0) + 1,
			 updated_at = NOW(), 
			 reputation = reputation - deduct_reputation
 	  WHERE users.id = user_id;

	/*insert into tran*/
	INSERT INTO reputation_transactions (created_at, question_id, updated_at, user_id, reputation) VALUES (NOW(), uuid, NOW(), user_id, deduct_reputation);
	
	COMMIT;
ELSE IF deduct_reputation = 0 AND deduct_credit > 0.00 THEN
	START TRANSACTION;
 	/* Create a new question */
	INSERT INTO questions (id, content, created_at, credit, title, updated_at, user_id) VALUES (uuid, content, NOW(), deduct_credit, title, NOW(), user_id);

	/* update user info*/
	UPDATE users
   		SET questions_count = COALESCE(questions_count, 0) + 1,
			 	 updated_at = NOW(), 
					 credit = credit - deduct_credit
 	  WHERE users.id = user_id;

	/*insert into tran*/
	INSERT INTO credit_transactions (created_at, question_id, updated_at, user_id, credit) VALUES (now(), uuid, now(), user_id, deduct_credit);
	
	COMMIT;
ELSE IF deduct_reputation > 0 AND deduct_credit > 0.00 THEN
	START TRANSACTION;
 	/* Create a new question */
	INSERT INTO questions (id, content, created_at, reputation, credit, title, updated_at, user_id) 
		 VALUES (uuid, content, NOW(), deduct_reputation, deduct_credit, title, NOW(), user_id);
	
	/* update user info*/
	UPDATE users
   		SET questions_count = COALESCE(questions_count, 0) + 1,
				 updated_at = NOW(), 
				 reputation = reputation - deduct_reputation,
			    	 credit = credit - deduct_credit
 	  WHERE users.id = user_id;

	/*insert into tran*/
	INSERT INTO reputation_transactions (created_at, question_id, updated_at, user_id, reputation) VALUES (NOW(), uuid, NOW(), user_id, deduct_reputation);
	INSERT INTO credit_transactions (created_at, question_id, updated_at, user_id, credit) VALUES (now(), uuid, now(), user_id, deduct_credit);
	
	COMMIT;
end if;
end if;
end if;
end if;
END