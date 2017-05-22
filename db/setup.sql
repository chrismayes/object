-- ***** TABLES *****

--TYPE
CREATE TABLE [dbo].[type](
	[id] [int] NOT NULL,
	[name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_type] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


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


--META
CREATE TABLE [dbo].[meta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](max) NOT NULL,
	[display_name] [nvarchar](max) NOT NULL,
	[type_id] [int] NOT NULL,
	[object_id] [int] NOT NULL,
 CONSTRAINT [PK_meta] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[meta]  WITH CHECK ADD  CONSTRAINT [FK_meta_object] FOREIGN KEY([object_id])
REFERENCES [dbo].[object] ([id])
ALTER TABLE [dbo].[meta] CHECK CONSTRAINT [FK_meta_object]
ALTER TABLE [dbo].[meta]  WITH CHECK ADD  CONSTRAINT [FK_meta_type] FOREIGN KEY([type_id])
REFERENCES [dbo].[type] ([id])
ALTER TABLE [dbo].[meta] CHECK CONSTRAINT [FK_meta_type]



--VALUE
CREATE TABLE [dbo].[value](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[meta_id] [int] NOT NULL,
	[value] [nvarchar](max) NULL,
 CONSTRAINT [PK_value] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[value]  WITH CHECK ADD  CONSTRAINT [FK_value_meta] FOREIGN KEY([meta_id])
REFERENCES [dbo].[meta] ([id])
ALTER TABLE [dbo].[value] CHECK CONSTRAINT [FK_value_meta]


--JOIN_TYPE
CREATE TABLE [dbo].[join_type](
	[id] [int] NOT NULL,
	[name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_join_type] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


--OBJECT_JOIN
CREATE TABLE [dbo].[object_join](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[parent_id] [int] NOT NULL,
	[child_id] [int] NOT NULL,
	[join_type_id] [int] NOT NULL,
 CONSTRAINT [PK_object_join] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[object_join]  WITH CHECK ADD  CONSTRAINT [FK_object_join_join_type] FOREIGN KEY([join_type_id])
REFERENCES [dbo].[join_type] ([id])
ALTER TABLE [dbo].[object_join] CHECK CONSTRAINT [FK_object_join_join_type]
ALTER TABLE [dbo].[object_join]  WITH CHECK ADD  CONSTRAINT [FK_object_join_object] FOREIGN KEY([parent_id])
REFERENCES [dbo].[object] ([id])
ALTER TABLE [dbo].[object_join] CHECK CONSTRAINT [FK_object_join_object]
ALTER TABLE [dbo].[object_join]  WITH CHECK ADD  CONSTRAINT [FK_object_join_object1] FOREIGN KEY([child_id])
REFERENCES [dbo].[object] ([id])
ALTER TABLE [dbo].[object_join] CHECK CONSTRAINT [FK_object_join_object1]


--JOIN_META
CREATE TABLE [dbo].[join_meta](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](max) NOT NULL,
	[display_name] [nvarchar](max) NOT NULL,
	[join_type_id] [int] NOT NULL,
	[object_join_id] [int] NOT NULL,
 CONSTRAINT [PK_join_meta] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
ALTER TABLE [dbo].[join_meta]  WITH CHECK ADD  CONSTRAINT [FK_join_meta_join_type] FOREIGN KEY([join_type_id])
REFERENCES [dbo].[join_type] ([id])
ALTER TABLE [dbo].[join_meta] CHECK CONSTRAINT [FK_join_meta_join_type]
ALTER TABLE [dbo].[join_meta]  WITH CHECK ADD  CONSTRAINT [FK_join_meta_object_join] FOREIGN KEY([object_join_id])
REFERENCES [dbo].[object_join] ([id])
ALTER TABLE [dbo].[join_meta] CHECK CONSTRAINT [FK_join_meta_object_join]



--JOIN_VALUE
CREATE TABLE [dbo].[join_value](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[join_meta_id] [int] NOT NULL,
	[value] [nvarchar](max) NULL,
 CONSTRAINT [PK_join_value] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[join_value]  WITH CHECK ADD  CONSTRAINT [FK_join_value_join_meta] FOREIGN KEY([join_meta_id])
REFERENCES [dbo].[join_meta] ([id])
ALTER TABLE [dbo].[join_value] CHECK CONSTRAINT [FK_join_value_join_meta]



-- ***** DATA *****
INSERT INTO type(id, name) VALUES(1, 'root')
INSERT INTO type(id, name) VALUES(10, 'object')

INSERT INTO join_type(id, name) VALUES(1, 'basic')

INSERT INTO object(name, type_id) VALUES('root', 1)
INSERT INTO object(name, type_id) VALUES('example', 10)

INSERT INTO object_join(parent_id, child_id, join_type_id) VALUES(1, 2, 1)

INSERT INTO join_meta(name, display_name, join_type_id, object_join_id) VALUES('relationship', 'Relationship', 1, 1)
INSERT INTO join_meta(name, display_name, join_type_id, object_join_id) VALUES('origin', 'Origin', 1, 1)
INSERT INTO join_value(join_meta_id, value) VALUES(1, 'The example object is connected to the root object.')
INSERT INTO join_value(join_meta_id, value) VALUES(2, 'Created by the developer.')
INSERT INTO join_value(join_meta_id, value) VALUES(2, 'Autocreated by setup script.')

INSERT INTO meta(name, display_name, type_id, object_id) VALUES('description', 'Description', 10, 2)
INSERT INTO value(meta_id, value) VALUES(1, 'This is the first object created in the database as an example. Feel free to delete it.')



-- ***** RESET *****
--DROP TABLE join_value
--DROP TABLE join_meta
--DROP TABLE object_join
--DROP TABLE join_type
--DROP TABLE value
--DROP TABLE meta
--DROP TABLE object
--DROP TABLE type

