--TYPE
CREATE TABLE [dbo].[type](
	[id] [int] NOT NULL,
	[name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_type] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

INSERT INTO type(id, name)
VALUES(1, 'root')
INSERT INTO type(id, name)
VALUES(10, 'object')


--OBJECT
CREATE TABLE [dbo].[object](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](max) NOT NULL,
	[type_id] [int] NOT NULL,
 CONSTRAINT [PK_object] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[object]  WITH CHECK ADD  CONSTRAINT [FK_object_type] FOREIGN KEY([type_id])
REFERENCES [dbo].[type] ([id])

ALTER TABLE [dbo].[object] CHECK CONSTRAINT [FK_object_type]

INSERT INTO object(name, type_id)
VALUES('root', 1)


--OBJECT_JOIN
CREATE TABLE [dbo].[object_join](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[parent_id] [int] NOT NULL,
	[child_id] [int] NOT NULL,
 CONSTRAINT [PK_object_join] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[object_join]  WITH CHECK ADD  CONSTRAINT [FK_object_join_object] FOREIGN KEY([parent_id])
REFERENCES [dbo].[object] ([id])

ALTER TABLE [dbo].[object_join] CHECK CONSTRAINT [FK_object_join_object]

ALTER TABLE [dbo].[object_join]  WITH CHECK ADD  CONSTRAINT [FK_object_join_object1] FOREIGN KEY([child_id])
REFERENCES [dbo].[object] ([id])

ALTER TABLE [dbo].[object_join] CHECK CONSTRAINT [FK_object_join_object1]


--Reset
--DROP TABLE object_join
--DROP TABLE object
--DROP TABLE type
