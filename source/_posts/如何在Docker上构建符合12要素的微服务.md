title: 如何在Docker上构建符合12要素的微服务
tags:
  - 12-factor
  - 微服务
  - Docker
categories:
  - 翻译
date: 2018-05-12 09:34:00
---
## 如何在Docker上构建符合12要素的微服务

原文地址：[How to Build 12 Factor Microservices on Docker](https://hub.packtpub.com/how-to-build-12-factor-design-microservices-on-docker-part-1/)

原文由两部分构成，我和并处理了，并去掉原先两部分中间过渡的引语。文章有删减处理，有些地方确实拿捏不准，翻译可能南辕北辙，望见谅。最后感谢[Google 翻译](https://translate.google.cn/),完成了90%的翻译


As companies continue to reap benefits of the cloud beyond cost savings, devops teams are gradually transforming their infrastructure into a self-serve platform. Critical to this effort is designing applications to be cloud-native and antifragile. In this post series, we will examine the 12 factor methodology for application design, how this design approach interfaces with some of the more popular Platform-as-a-Service (PaaS) providers, and demonstrate how to run such microservices on the Deis PaaS.

随着企业持续从云计算上获得节约成本的好处，`Devops`团队正逐渐把他们的基础架构迁移到自服务平台。如何将应用设计成云原生和反脆弱成了至关重要的工作。在接下里的一系列文章里面，我们将研究用于应用设计的12要素方法论，以及怎样设计接口来和大部分流行的`Pass`提供者交互，以及演示怎么在`Deis PaaS`上运行一个微服务


What began as Service Oriented Architectures in the data center are realizing their full potential as microservices in the cloud, led by innovators such as Netflix and Heroku. Netflix was arguably the first to design their applications to not only be resilient but to be antifragile; that is, by intentionally introducing chaos into their systems, their applications become more stable, scalable, and graceful in the presence of errors. Similarly, by helping thousands of clients building cloud applications, Heroku recognized a set of common patterns emerging and set forth the 12 factor methodology.

由`Netfix`和`Heroku`等创新者的引领下，面向服务架构的数据中心正意识到在云上采用微服务的巨大潜力。`Netfix`无可争议的是第一个设计出可伸缩和反脆弱的应用，也就是有意引入chaos到他们的系统，他们的应用在面对错误时候变得更加稳定、弹性、优雅。同样通过帮助成千上万的客户在云上构建应用，`Heroku`提出一系列通用原则并将它描述成12要素方法论


<!--more-->

###  ANTIFRAGILITY

### 反脆弱

You may have never heard of antifragility. This concept was introduced by Nassim Taleb, the author of Fooled by Randomness and The Black Swan. Essentially, antifragility is what gains from volatility and uncertainty (up to a point). Think of the MySQL server that everyone is afraid to touch lest it crash vs the Cassandra ring which can handle the loss of multiple servers without a problem. In terms more familiar to the tech crowd, a “pet” is fragile while “cattle” are antifragile (or at least robust, that is, they neither gain nor lose from volatility).

你也许从没有听说过反脆弱。这个概念由《无心的愚蠢》和《黑天鹅》的作者Nassim Taleb提出来的。从本质性来讲，反脆弱从波动性和不确定性（上升到某点）中获得。想一想每个人都害怕触碰的MySQL服务器以免它崩溃和处理多服务器丢失的问题的Cassandra ring。用科技人群更熟悉的话语来说，宠物是脆弱的，而家畜是反脆弱的（或者是强壮的，至少他们从来没有从波动性中获得或失去什么）


Adrian Cockroft seems to have discovered this concept with his team at Netflix. During their transition from a data center to Amazon Web Services, they claimed that “the best way to avoid failure is to fail constantly.” (http://techblog.netflix.com/2010/12/5-lessons-weve-learned-using-aws.html) To facilitate this process, one of the first tools Netflix built was Chaos Monkey, the now-infamous tool which kills your Amazon instances to see if and how well your application responds. By constantly injecting failure, their engineers were forced to design their applications to be more fault tolerant, to degrade gracefully, and to be better distributed so as to avoid any Single Points Of Failure (SPOF). As a result, Netflix has a whole suite of tools which form the Netflix PaaS. Many of these have been released as part of the Netflix OSS ecosystem.

Adrian Cockroft和他的团队似乎是在`Netflix`中发现了这个概念。
在从数据中心切换到亚马逊Web服务（Amazon Web Services）的过程中，他们声称“[避免失败的最佳方式是不断失败](http://techblog.netflix.com/2010/12/5-lessons-weve-learned
-using-aws.html)”。为了促进转换进程，Netflix建立的第一个工具是Chaos Monkey，它是一个臭名昭著的工具，它会杀死你的亚马逊实例，以查看你的应用程序是否响应以及如何响应。
通过持续注入故障，他们的工程师不得不设计他们的应用程序，使其更具容错性，能够优雅地降级，并且更好地分布以避免任何单点故障（SPOF）。

因此，`Netflix`拥有一整套构成`Netflix PaaS`的工具，其中许多已经作为`Netflix OSS`生态系统的一部分发布。



### 12 FACTOR APPS

### 12要素应用

Because many companies want to avoid relying too heavily on tools from any single third-party, it may be more beneficial to look at the concepts underlying such a cloud-native design. This will also help you evaluate and compare multiple options for solving the core issues at hand. Heroku, being a platform on which thousands or millions of applications are deployed, have had to isolate the core design patterns for applications which operate in the cloud and provide an environment which makes such applications easy to build and maintain. These are described as a manifesto entitled the 12-Factor App.

由于许多公司希望避免过分依赖任何单一第三方提供的工具，因此了解这种云原生设计的基本概念可能更为有利。这也将帮助您评估和比较多种解决方案来解决手头的核心问题。

Heroku作为一个数千或数百万应用程序部署的平台，应用程序的核心设计模式是必须隔离运行，并提供一个使这些应用程序易于构建和维护的环境。这些被描述是一个号称12要素应用的宣言。

The first part of this post walks through the first five factors and reworks a simple python webapp with them in mind. Part 2 continues with the remaining seven factors, demonstrating how this design allows easier integration with cloud-native containerization technologies like Docker and Deis.

本文的第一部分介绍了前五个因素，并重新编写了一个简单的python webapp。第2部分继续讨论其余七个因素，展示了这种设计如何更容易地与Docker和Deis等云本地容器化技术集成。

Let’s say we’re starting with a minimal python application which simply provides a way to view some content from a relational database. We’ll start with a single-file application, app.py.

假设我们从一个最小的python应用程序开始，它只是提供一种查看关系数据库中某些内容的方法。我们将从一个单一文件应用程序的app.py开始。

```python
from flask import Flask
import mysql.connector as db
import json

app = Flask(__name__)

def execute(query):
   con = None
   try:
       con = db.connect(host='localhost', user='testdb', password='t123', database='testdb')
       cur = con.cursor()
       cur.execute(query)
       return cur.fetchall()
   except db.Error, e:
       print "Error %d: %s" % (e.args[0], e.args[1])
       return None
   finally:
       if con:
           con.close()

def list_users():
   users = execute("SELECT id, username, email FROM users") or []
   return [{"id": user_id, "username": username, "email": email} for (user_id, username, email) in users]

@app.route("/users")
def users_index():
   return json.dumps(list_users())

if __name__ == "__main__":
   app.run(host='0.0.0.0', port=5000, debug=True)
```

We can assume you have a simple mysql database setup already.

我们可以假设你已经有了一个简单的mysql数据库配置。

```sql
CREATE DATABASE testdb;
CREATE TABLE users (
           id INT NOT NULL AUTO_INCREMENT,
           username VARCHAR(80) NOT NULL,
           email VARCHAR(120) NOT NULL,
           PRIMARY KEY (id),
           UNIQUE INDEX (username),
           UNIQUE INDEX (email)
);
INSERT INTO users VALUES (1, "admin", "admin@example.com");
INSERT INTO users VALUES (2, "guest", "guest@example.com");
```

As you can see, the application is currently implemented as about the most naive approach possible and contained within this single file.

正如您所看到的，该应用程序目前的实现方式是尽可能使用最简单的方法，并将其包含在此单个文件中。

We’ll now walk step-by-step through the 12 Factors and apply them to this simple application.

我们现在将逐步介绍12要素并将它们应用到这个简单的应用程序中。

### THE 12 FACTORS: STEP BY STEP

### 12要素：Step By Step


#### 1. Codebase

#### 1. 基准代码

A 12-factor app is always tracked in a version control system, such as Git, Mercurial, or Subversion. If there are multiple codebases, its a distributed system in which each component may be a 12-factor app. There are many deploys, or running instances, of each application, including production, staging, and developers’ local environments.

一个12要素应用总是在版本控制系统中进行跟踪，例如`Git`，`Mercurial`或`Subversion`。如果有多个代码库，它是一个分布式系统，其中每个组件可能是一个12要素应用。每个应用都有许多部署或运行实例，包括生产，预发布和开发人员的本地环境。

Since many people are familiar with git today, let’s choose that as our version control system. We can initialize a git repo for our new project.

由于现在很多人都熟悉`git`，我们选择它作为我们的版本控制系统。我们可以为我们的新项目初始化一个`git repo`。


First ensure we’re in the app directory which, at this point, only contains the single app.py file.

首先确保我们在app目录中，此目录中只包含单个`app.py`文件。

```bash
cd 12factor
git init .
```

After adding the single app.py file, we can commit to the repo.

在添加`app.py`文件后，我们把它提交到仓库里面。

```bash
git add app.py
git commit -m "Initial commit"
```

#### 2. Dependencies. 

#### 2. 依赖

All dependencies must be explicitly declared and isolated. A 12-factor app never depends on packages to be installed system-wide and uses a dependency isolation tool during execution to stop any system-wide packages from “leaking in.” 

所有依赖关系必须明确声明和隔离。12要素应用从不依赖于要在系统范围内安装的软件包，并在执行期间使用依赖性隔离工具来阻止任何系统范围的软件包“泄漏”。

Good examples are Gem Bundler for Ruby (Gemfile provides declaration and `bundle exec` provides isolation) and Pip/requirements.txt and Virtualenv for Python (where pip/requirements.txt provides declaration and `virtualenv –no-site-packages` provides isolation).

很好的例子有`Ruby`的`Gem Bundler`（`Gemfile`提供声明，`bundle exec`提供隔离），`Python`的`Pip/requirements.txt`和`Virtualenv`（其中`pip/requirements.txt`提供声明，`virtualenv -no-site-packages`提供隔离）。

We can create and use (source) a virtualenv environment which explicitly isolates the local app’s environment from the global “site-packages” installations.

我们可以创建一个`virtualenv`环境，它直接将本地应用程序的环境与全局“site-packages”安装隔离。

```bash
virtualenv env --no-site-packages
source env/bin/activate
```

A quick glance at the code we’ll show that we’re only using two dependencies currently, flask and mysql-connector-python, so we’ll add them to the requirements file.

快速浏览代码，我们将展示我们目前只使用的两个依赖关系，即`flask`和`mysql-connector-python`，因此我们将它们添加到依赖文件中。

```bash
echo flask==0.10.1 >> requirements.txt
echo mysql-python==1.2.5 >> requirements.txt
```

Let’s use the requirements file to install all the dependencies into our isolated virtualenv.

让我们使用依赖文件将所有依赖关系安装到我们独立的`virtualenv`中。

```
pip install -r requirements.txt
```

#### 3. Config

#### 3. 配置

An app’s config must be stored in environment variables. This config is what may vary between deploys in developer environments, staging, and production. The most common example is the database credentials or resource handle.

应用程序的配置必须存储在环境变量中。同一份配置在开发，预生产和生产环境之间可能会有所不同。最常见的例子是数据库连接配置或资源配置。

We currently have the host, user, password, and database name hardcoded. Hopefully you’ve at least already extracted this to a configuration file; either way, we’ll be moving them to environment variables instead.

我们目前拥有已经硬编码的主机，用户，密码和数据库名称。希望你至少已经提取出这个配置文件里面的配置，无论怎么样我们都必须将它们转换为环境变量。


```python
import os

DATABASE_CREDENTIALS = {
   'host': os.environ['DATABASE_HOST'],
   'user': os.environ['DATABASE_USER'],
   'password': os.environ['DATABASE_PASSWORD'],
   'database': os.environ['DATABASE_NAME']
}
```

Don’t forget to update the actual connection to use the new credentials object:

不要忘记更新连接以便使用新的凭据对象：

```bash
con = db.connect(**DATABASE_CREDENTIALS)
```


#### 4. Backing Services

#### 4. 后端服务


A 12-factor app must make no distinction between a service running locally or as a third-party. For example, a deploy should be able to swap out a local MySQL database with a third-party replacement such as Amazon RDS without any code changes, just by updating a URL or other handle/credentials inside the config.

一个12要素应用程序必须不区分在本地或作为第三方运行的服务。例如部署应该能够使用第三方替换（如`Amazon RDS`）替换本地MySQL数据库，而无需修改任何代码，只需修改配置中的URL或其他句柄/凭证即可。

Using a database abstraction layer such as SQLAlchemy (or your own adapter) lets you treat many backing services similarly so that you can switch between them with a single configuration parameter. In this case, it has the added advantage of serving as an Object Relational Mapper to better encapsulate our database access logic.

使用数据库抽象层（如`SQLAlchemy`（或您自己的适配器））可以让您类似地处理许多后台服务，以便您可以使用单个配置参数在它们之间进行切换。在这种情况下，它具有作为对象关系映射器的附加优势，可以更好地封装数据库访问逻辑。

We can replace the hand-rolled execute function and SELECT query with a model object

我们可以用模型对象替换手动执行函数和SELECT查询

```bash
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ['DATABASE_URL']
db = SQLAlchemy(app)

class User(db.Model):
   __tablename__ = 'users'
   id = db.Column(db.Integer, primary_key=True)
   username = db.Column(db.String(80), unique=True)
   email = db.Column(db.String(120), unique=True)

   def __init__(self, username, email):
       self.username = username
       self.email = email

   def __repr__(self):
       return '<User %r>' % self.username

@app.route("/users")
def users_index():
   to_json = lambda user: {"id": user.id, "name": user.username, "email": user.email}
   return json.dumps([to_json(user) for user in User.query.all()])
```

Now we set the DATABASE_URL environment property to something like

现在我们将DATABASE_URL环境属性设置为类似下面变量

```
export DATABASE_URL=mysql://testdb:t123@localhost/testdb
```

But its should be easy to switch to Postgres or Amazon RDS (still backed by MySQL).

但它应该很容易切换到Postgres或Amazon RDS（仍由MySQL支持）。

```
DATABASE_URL=postgresql://testdb:t123@localhost/testdb
```

We’ll continue this demo using a MySQL cluster provided by Amazon RDS.

我们将继续使用Amazon RDS提供的MySQL集群进行此演示。

```
DATABASE_URL=mysql://sa:mypwd@mydbinstance.abcdefghijkl.us-west-2.rds.amazonaws.com/mydb
```

As you can see, this makes attaching and detaching from different backing services trivial from a code perspective, allowing you to focus on more challenging issues. This is important during the early stages of code because it allows you to performance test multiple databases and third-party providers against one another, and in general keeps with the notion of avoiding vendor lock-in.

正如你所看到的，这使得从代码的角度来看，不同的后台服务是不重要的，可以让你专注于更具挑战性的问题。这在代码的早期阶段非常重要，因为它允许您对多个数据库和第三方提供者进行性能测试，并且总体上遵循避免供应商过度依赖的理念。


#### 5. Build, Release, Run

#### 5. 构建，发布，运行


A 12-factor app strictly separates the process for transforming a codebase into a deploy into distinct build, release, and run stages. 

The build stage creates an executable bundle from a code repo, including vendoring dependencies and compiling binaries and asset packages. 

The release stage combines the executable bundle created in the build with the deploy’s current config. Releases are immutable and form an append-only ledger; consequently, each release must have a unique release ID. 

The run stage runs the app in the execution environment by launching the app’s processes against the release.

一个12要素应用将代码转换成部署的过程严格区分为不同的构建，发布和运行阶段。

构建阶段通过代码仓库创建可执行包，包括依赖包和编译二进制文件和资源包。

发布阶段将在构建中创建的可执行包与部署的当前配置相结合。版本是不可改变的，并形成仅能追加的记录;因此每个版本都必须具有唯一的版本ID。

运行阶段通过启动应用程序的进程来在执行环境中运行应用程序。

This is where your operations meet your development and where a PaaS can really shine. For now, we’re assuming that we’ll be using a Docker-based containerized deploy strategy. We’ll start by writing a simple Dockerfile.

这就是你的操作符合你的发展和PaaS真正发挥的地方。目前，我们假设我们将使用基于`Docker`的容器化部署策略。我们将首先编写一个简单的`Dockerfile`。

The Dockerfile starts with an ubuntu base image and then I add myself as the maintainer of this app.

`Dockerfile`从一个`ubuntu`的基础映像开始，然后添加自己作为这个应用程序的维护者。

```bash
FROM ubuntu:14.04.2
MAINTAINER codyaray
```

Before installing anything, let’s make sure that apt has the latest versions of all the packages.

在安装任何东西之前，让我们确保apt具有所有软件包的最新版本。

```bash
RUN echo "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc) main universe" >> /etc/apt/sources.list
RUN apt-get update

```

Install some basic tools and the requirements for running a python webapp

安装一些基本工具和运行python webapp的依赖

```
RUN apt-get install -y tar curl wget dialog net-tools build-essential
RUN apt-get install -y python python-dev python-distribute python-pip
RUN apt-get install -y libmysqlclient-dev
```

Copy over the application to the container.

将应用程序复制到容器。

```
ADD /. /src
```

Install the dependencies.
安装依赖

```
RUN pip install -r /src/requirements.txt
```

Finally, set the current working directory, expose the port, and set the default command.

最后，设置当前工作目录，暴露端口并设置默认执行命令。

```
EXPOSE 5000
WORKDIR /src
CMD python app.py
```

Now, the build phase consists of building a docker image. You can build and store locally with

现在，构建阶段包括构建`docker`镜像。你可以在本地构建和存储

```
docker build -t codyaray/12factor:0.1.0 .
```

If you look at your local repository, you should see the new image present.

如果你看看你的本地仓库，你可以看到新的镜像。

```
$ docker images
REPOSITORY          TAG     IMAGE ID         CREATED       VIRTUAL SIZE
codyaray/12factor   0.1.0   bfb61d2bbb17     1 hour ago    454.8 MB
```

The release phase really depends on details of the execution environment. You’ll notice that none of the configuration is stored in the image produced from the build stage; however, we need a way to build a versioned release with the full configuration as well.

发布阶段取决于执行环境的细节。您会注意到，没有任何配置存储在构建阶段生成的镜像中;我们需要一种方法来构建具有完整配置的发布版本。

Ideally, the execution environment would be responsible for creating releases from the source code and configuration specific to that environment. However, if we’re working from first principles with Docker rather than a full-featured PaaS, one possibility is to build a new docker image using the one we just built as a base. Each environment would have its own set of configuration parameters and thus its own Dockerfile. It could be something as simple as

理想情况下，执行环境将负责从特定于该环境的源代码和配置创建发行版。但是，如果我们遵循Docker的第一原则而不是全功能的PaaS，那么一种可能性是使用我们刚刚构建镜像作为基础镜像来构建一个新的Docker镜像。每个环境都有自己的一组配置参数，因此也有自己的Dockerfile。这可能是一件简单的事情。

```
FROM codyaray/12factor:0.1.0
MAINTAINER codyaray

ENV DATABASE_URL mysql://sa:mypwd@mydbinstance.abcdefghijkl.us-west-2.rds.amazonaws.com/mydb
```

This is simple enough to be programmatically generated given the environment-specific configuration and the new container version to be deployed. For the demonstration purposes, though, we’ll call the above file Dockerfile-release so it doesn’t conflict with the main application’s Dockerfile. Then we can build it with

它是足够简单到可以程序化生成针对特定环境的配置和待部署版本的容器
为了演示的目的，我们将调用上述文件`Dockerfile-release`，以免与主应用程序的`Dockerfile`发生冲突。然后我们可以用它来构建

```
docker build -f Dockerfile-release -t codyaray/12factor-release:0.1.0.0 .
```

The resulting built image could be stored in the environment’s registry as codyaray/12factor-release:0.1.0.0. The images in this registry would serve as the immutable ledger of releases. Notice that the version has been extended to include a fourth level which, in this instance, could represent configuration version “0” applied to source version “0.1.0”.

生成的镜像可以作为`codyaray/12factor-release:0.1.0.0`存储在环境的注册中心中。这个注册中心中的镜像将作为发布的不可变版本。请注意，该版本已被扩展为包含第四级，在这种情况下，该级可以表示应用于原始版本“0.1.0”的配置版本“0”。

The key here is that these configuration parameters aren’t collated into named groups (sometimes called “environments”). For example, these aren’t static files named like Dockerfile.staging or Dockerfile.dev in a centralized repo. Rather, the set of parameters is distributed so that each environment maintains its own environment mapping in some fashion. The deployment system would be setup such that a new release to the environment automatically applies the environment variables it has stored to create a new Docker image.

这里的关键是这些配置参数不会被整理到命名组（有时称为“环境”）。例如，这些文件不是名为`Dockerfile.staging`或`Dockerfile.dev`的静态文件。而是，这组参数是分布式的，以便每个环境以某种方式维护其自己的环境映射。部署系统将设置为向环境的新版本自动应用其存储的环境变量以创建新的Docker映像。

As always, the final deploy stage depends on whether you’re using a cluster manager, scheduler, etc. If you’re using standalone Docker, then it would boil down to

与往常一样，最终的部署阶段取决于您是否使用集群管理器，调度程序等。如果您使用的是独立的Docker，那么它将归结为:

```
docker run -P -t codyaray/12factor-release:0.1.0.0
```

#### 6. Processes

#### 6. 进程

A 12-factor app is executed as one or more stateless processes which share nothing and are horizontally partitionable. 

All data which needs to be stored must use a stateful backing service, usually a database. This means no sticky sessions and no in-memory or local disk-based caches. These processes should never daemonize or write their own PID files; rather, they should rely on the execution environment’s process manager (such as Upstart).


This factor must be considered up-front, in line with the discussions on antifragility, horizontal scaling, and overall application design. As the example app delegates all stateful persistence to a database, we’ve already succeeded on this point.

一个12要素应用作为一个或多个无状态进程执行，它们不共享任何内容并且可水平分区。

所有需要存储的数据都必须使用状态支持服务，通常是数据库。这意味着没有粘性会话，没有内存或本地基于磁盘的缓存。这些进程不应该是守护进程或写自己的PID文件;相反，他们应该依赖执行环境的进程管理器（比如Upstart）。

这个因素必须预先考虑，使其符合反脆弱，横向扩展和总体应用设计的讨论。正如示例应用程序将所有有状态持久性委托给数据库一样，我们在这一点上已经取得了成功。

However, it is good to note that a number of issues have been found using the standard ubuntu base image for Docker, one of which is its process management (or lack thereof). If you would like to use a process manager to automatically restart crashed daemons, or to notify a service registry or operations team, check out baseimage-docker. This image adds runit for process supervision and management, amongst other improvements to base ubuntu for use in Docker such as obsoleting the need for pid files.

值得注意的是，使用Docker的标准ubuntu基础镜像发现了很多问题，其中之一就是它的进程管理（或缺乏）。如果您想使用进程管理器自动重启崩溃的进程，或者通知服务注册中心或操作团队，请查看baseimage-docker。此镜像为进程监督和管理添加了runit，以及其他的改进，例如废弃对pid文件的需求。

To use this new image, we have to update the Dockerfile to set the new base image and use its init system instead of running our application as the root process in the container.

要使用这个新镜像，我们必须更新`Dockerfile`来设置新的基础镜像并使用它的init系统，而不是将容器中的根进程作为我们的应用程序运行。

```
FROM phusion/baseimage:0.9.16
MAINTAINER codyaray

RUN echo "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc) main universe" >> /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y tar git curl nano wget dialog net-tools build-essential
RUN apt-get install -y python python-dev python-distribute python-pip
RUN apt-get install -y libmysqlclient-dev

ADD /. /src

RUN pip install -r /src/requirements.txt

EXPOSE 5000

WORKDIR /src

RUN mkdir /etc/service/12factor
ADD 12factor.sh /etc/service/12factor/run

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
```

Notice the file 12factor.sh that we’re now adding to /etc/service. This is how we instruct runit to run our application as a service.

注意我们现在添加到`/etc/service`的文件`12factor.sh`。这就是我们如何指示runit将我们的应用程序作为服务运行的方式。

Let’s add the new 12factor.sh file.

我们添加新的`12factor.sh`文件。

```bash
#!/bin/sh
python /src/app.py
```

Now the new containers we deploy will attempt to be a little more fault-tolerant by using an OS-level process manager.

现在，我们部署的新容器将尝试通过使用系统级别(OS-level)的进程管理器来实现更多的容错功能。

#### 7. Port Binding

#### 7. 端口绑定

A 12-factor app must be self-contained and bind to a port specified as an environment variable. It can’t rely on the injection of a web container such as tomcat or unicorn; instead it must embed a server such as jetty or thin. The execution environment is responsible for routing requests from a public-facing hostname to the port-bound web process.

12要素应用必须是自包含的，并且绑定到环境变量指定的端口。它不能依靠注入的诸如`tomcat`或`unicorn`之类的web容器;相反，它必须内置一个服务器，如比如`jetty`或者`thin`。执行环境负责将请求从公网的主机转发到到端口绑定的Web进程。

This is trivial with most embedded web servers. If you’re currently using an external web server, this may require more effort to support an embedded server within your application. For the example python app (which uses the built-in flask web server), it boils down to

对于大多数内置Web服务器来说这是微不足道的。如果您当前正在使用外部Web服务器，则可能需要更多努力来支持应用程序中的内置服务器。对于示例python应用程序（使用内置的flask Web服务器），它用法如下：

```bash
port = int(os.environ.get("PORT", 5000))
app.run(host='0.0.0.0', port=port)
```

Now the execution environment is free to instruct the application to listen on whatever port is available. This obviates the need for the application to tell the environment what ports must be exposed, as we’ve been required to do with Docker.

现在执行环境可以自由地指示应用程序侦听任何可用的端口。这避免了应用程序需要告诉环境哪些端口必须被暴露，因为我们需要使用Docker。

#### 8. Concurrency

#### 8. 并发

Because a 12-factor exclusively uses stateless processes, it can scale out by adding processes. A 12-factor app can have multiple process types, such as web processes, background worker processes, or clock processes (for cron-like scheduled jobs).

由于12要素专门使用无状态进程，因此可以通过添加进程来扩展。一个12要素应用可以有多种流程类型，例如web进程，后台工作进程或时钟进程（对于类似cron的作业调度）。

As each process type is scaled independently, each logical process would become its own Docker container as well. We’ve already seen building a web process; other processes are very similar. In most cases, scaling out simply means launching more instances of the container. (Its usually not desirable to scale out the clock processes, though, as they often generate events that you want to be scheduled singletons within your infrastructure.)

由于每个进程类型都是独立扩展的，因此每个逻辑进程也将成为它自己的Docker容器。我们已经看到构建一个Web过程;其他流程非常相似。在大多数情况下，扩展仅仅意味着启动容器的更多实例。（但是，通常不希望扩展时钟进程，因为它们通常会生成要在基础结构中安排单例的事件）

#### 9. Disposability

#### 9. 易处理

A 12-factor app’s processes can be started or stopped (with a SIGTERM) anytime. Thus, minimizing startup time and gracefully shutting down is very important. For example, when a web service receives a SIGTERM, it should stop listening on the HTTP port, allow in-flight requests to finish, and then exit. Similar, processes should be robust against sudden death; for example, worker processes should use a robust queuing backend.

随时可以启动或停止12要素应用进程（使用SIGTERM）。因此最短启动时间并优雅地关闭是非常重要的。例如当Web服务收到SIGTERM时，它应该停止在HTTP端口上侦听，允许进行中的请求完成，然后退出。类似，进程应该足够健壮来应对sudden death;例如，工作进程应该使用健壮的队列后端。

You want to ensure the web server you select can gracefully shutdown. The is one of the trickier parts of selecting a web server, at least for many of the common python http servers that I’ve tried.

您希望确保您选择的Web服务器可以正常关闭。这是选择Web服务器的一个棘手的部分，至少对于我尝试过的许多常见的Python HTTP服务器来说。

In theory, shutting down based on receiving a SIGTERM should be as simple as follows.

理论上讲，基于接收SIGTERM的关闭应该如下简单：

```python
import signal
signal.signal(signal.SIGTERM, lambda *args: server.stop(timeout=60))
```

But often times, you’ll find that this will immediately kill the in-flight requests as well as closing the listening socket. You’ll want to test this thoroughly if dependable graceful shutdown is critical to your application.

但是通常情况下，你会发现这将立即杀死正在进行的请求并关闭侦听套接字。如果可靠的正常关机对于你的应用程序至关重要，你需要彻底地进行测试。

#### 10. Dev/Prod Parity 

#### 10. 开发环境与线上环境等价

A 12-factor app is designed to keep the gap between development and production small. Continuous deployment shrinks the amount of time that code lives in development but not production. A self-serve platform allows developers to deploy their own code in production, just like they do in their local development environments. Using the same backing services (databases, caches, queues, etc) in development as production reduces the number of subtle bugs that arise in inconsistencies between technologies or integrations.

一个12要素应用旨在保持开发和生产之间的差距很小。持续部署缩短了代码在开发中的时间，而不是生产。自助平台允许开发人员在生产环境中部署自己的代码，就像他们在本地开发环境中一样。在开发过程中使用相同的后端服务（数据库，缓存，队列等）可以减少技术或集成之间不一致时产生的细微缺陷数量。

As we’re deploying this solution using fully Dockerized containers and third-party backing services, we’ve effectively achieved dev/prod parity. For local development, I use boot2docker on my Mac which provides a Docker-compatible VM to host my containers. Using boot2docker, you can start the VM and setup all the env variables automatically with

由于我们使用完全Docker化的容器和第三方后端服务来部署此解决方案，因此我们有效地实现了开发环境与线上环境等价。对于本地开发，我在我的Mac上使用boot2docker，它提供了一个兼容Docker的虚拟机来托管我的容器。使用boot2docker，你可以启动虚拟机并自动设置所有的env变量

```
boot2docker up
$(boot2docker shellinit)
```

Once you’ve initialized this VM and set the DOCKER_HOST variable to its IP address with shellinit, the docker commands given above work exactly the same for development as they do for production.

一旦你初始化了这个虚拟机，并用shellinit将DOCKER_HOST变量设置为它的IP地址，上面给出的docker命令在开发过程中的工作方式与生产上完全相同。

#### 11. Logs

#### 11. 日志

Consider logs as a stream of time-ordered events collected from all running processes and backing services. A 12-factor app doesn’t concern itself with how its output is handled. Instead, it just writes its output to its `stdout` stream. The execution environment is responsible for collecting, collating, and routing this output to its final destination(s).

日志可以视为来自所有运行的进程或者后端服务，按照时间排序的事件集合构成的流一个12要素应用并不关心它的输出是如何处理的。相反，它只是将其输出写入其“stdout”流。执行环境负责收集，整理并将此输出到其最终目标。

Most logging frameworks either support logging to stderr/stdout by default or easily switching from file-based logging to one of these streams. In a 12-factor app, the execution environment is expected to capture these streams and handle them however the platform dictates.

大多数日志记录框架默认支持`stderr/stdout`日志记录，或者很容易从基于文件的日志记录切换到其中一个流。在一个12要素应用中，执行环境会捕获这些数据流并处理它们。

Because our app doesn’t have specific logging yet, and the only logs are from flask and already to stderr, we don’t have any application changes to make. 

因为我们的应用没有特别的日志，并且唯一的日志来自flask并且已经是`stderr`，所以我们并不需要对程序进行任何更改。

However, we can show how an execution environment which could be used handle the logs. We’ll setup a Docker container which collects the logs from all the other docker containers on the same host. Ideally, this would then forward the logs to a centralized service such as Elasticsearch. Here we’ll demo using Fluentd to capture and collect the logs inside the log collection container; a simple configuration change would allow us to switch from writing these logs to disk as we demo here and instead send them from Fluentd to a local Elasticsearch cluster.

但是，我们将展示一个可以用来处理日志的执行环境。我们将启动一个`Docker`容器，它收集来自同一主机上所有其他`Docker`容器的日志。理想情况下，这会将日志转发到`Elasticsearch`等集中式服务。在这里，我们将演示如何使用`Fluentd`来捕获和收集容器内的日志。一个简单的配置更改将允许我们从演示时的将日志写入磁盘，改成将它们从Fluentd发送到本地Elasticsearch集群。

We’ll create a Dockerfile for our new logcollector container type. For more detail, you can find a [Docker fluent tutorial](http://www.fluentd.org/guides/recipes/docker-logging) here. We can call this file Dockerfile-logcollector.

我们将为我们的新日志收集器容器创建一个`Dockerfile`。有关更多详细信息，可以在这里找到[Docker Fluent教程]（http://www.fluentd.org/guides/recipes/docker-logging）。我们可以调用这个文件`Dockerfile-logcollector`。

```
FROM kiyoto/fluentd:0.10.56-2.1.1
MAINTAINER kiyoto@treasure-data.com
RUN mkdir /etc/fluent
ADD fluent.conf /etc/fluent/
CMD "/usr/local/bin/fluentd -c /etc/fluent/fluent.conf"
```

We use an existing fluentd base image with a specific fluentd configuration. Notably this tails all the log files in /var/lib/docker/containers/<container-id>/<container-id>-json.log, adds the container ID to the log message, and then writes to JSON-formatted files inside /var/log/docker.

我们使用一个已经存在的`fluentd`基础镜像和特定的`fluentd configuration`。值得注意的是所有`/var/lib/docker/containers/<container-id>/<container-id>-json.log`中的日志文件会增加容器ID到日志消息里面,然后写入JSON格式的文件在`/var/log/docker`里面

```
<source>
 type tail
 path /var/lib/docker/containers/*/*-json.log
 pos_file /var/log/fluentd-docker.pos
 time_format %Y-%m-%dT%H:%M:%S
 tag docker.*
 format json
</source>
<match docker.var.lib.docker.containers.*.*.log>
 type record_reformer
 container_id ${tag_parts[5]}
 tag docker.all
</match>
<match docker.all>
 type file
 path /var/log/docker/*.log
 format json
 include_time_key true
</match>
```

As usual, we create a Docker image. Don’t forget to specify the logcollector Dockerfile.

照常，我们将创建一个Docker镜像。不要忘记指定日志收集器的`Dockerfile`。

```
docker build -f Dockerfile-logcollector -t codyaray/docker-fluentd .
```

We’ll need to mount two directories from the Docker host into this container when we launch it. Specifically, we’ll mount the directory containing the logs from all the other containers as well as the directory to which we’ll be writing the consolidated JSON logs.

我们需要在Docker主机启动时将两个目录从Docker主机挂载到这个容器中。具体来说，我们将挂载包含所有其他容器日志的目录以及我们将编写整合的JSON日志的目录。

```
docker run -d -v /var/lib/docker/containers:/var/lib/docker/containers -v /var/log/docker:/var/log/docker codyaray/docker-fluentd
```

Now if you check in the /var/log/docker directory, you’ll see the collated JSON log files. Note that this is on the docker host rather than in any container; if you’re using boot2docker, you can ssh into the docker host with boot2docker ssh and then check /var/log/docker.

现在，如果你进入`/var/log/docker`目录，您将看到整理后的JSON日志文件。请注意，这需要在docker主机上查看而不是在任何容器中;如果你使用的是`boot2docker`，你可以使用`boot2docker ssh`进入`docker`主机，然后检查`/ var/log/docker`。

#### 12. Admin Processes

#### 12. 管理进程

Any admin or management tasks for a 12-factor app should be run as one-off processes within a deploy’s execution environment. This process runs against a release using the same codebase and configs as any process in that release and uses the same dependency isolation techniques as the long-running processes.

对于12要素应用的任何后台管理任务都应作为部署的执行环境中的一次性进程运行。此进程针对使用相同代码库的发行版运行，并配置为该发行版中的任何进程，并使用与长期运行进程相同的依赖关系隔离技术。

This is really a feature of your app’s execution environment. If you’re running a Docker-like containerized solution, this may be pretty trivial.

这实际上是您的应用程序执行环境的一个功能。如果你正在运行一个类似`Docker`的容器化解决方案，这可能是相当微不足道的。

```
docker run -i -t --entrypoint /bin/bash codyaray/12factor-release:0.1.0.0
```

The -i flag instructs docker to provide interactive session, that is, to keep the input and output ttys attached. Then we instruct docker to run the /bin/bash command instead of another 12factor app instance. This creates a new container based on the same docker image, which means we have access to all the code and configs for this release.

`-i`标志指示`docker`提供交互式会话，即保持输入和输出ttys的连接。然后我们指示`docker`运行`/bin/bash`命令而不是另一个`12factor`应用程序实例。这将创建一个基于相同Docker镜像的新容器，这意味着我们可以访问此版本的所有代码和配置。

This will drop us into a bash terminal to do whatever we want. But let’s say we want to add a new “friends” table to our database, so we wrote a migration script add_friends_table.py. We could run it as follows:

这会让我们进入一个bash终端来做我们想做的事情。比如我们想为我们的数据库添加一个新的“friends”表，我们可以编写了一个迁移脚本add_friends_table.py。我们可以运行它如下：

```bash
docker run -i -t --entrypoint python codyaray/12factor-release:0.1.0.0 /src/add_friends_table.py
```

As you can see, following the few simple rules specified in the 12 Factor manifesto really allows your execution environment to manage and scale your application. While this may not be the most feature-rich integration within a PaaS, it is certainly very portable with a clean separation of responsibilities between your app and its environment. Much of the tools and integration demonstrated here were a do-it-yourself container approach to the environment, which would be subsumed by an external vertically integrated PaaS such as [Deis](http://deis.io/).

正如您所看到的，遵循12要素宣言中指定的几条简单规则确实可以让您的执行环境管理和扩展您的应用程序。虽然这可能不是PaaS中功能最丰富的集成，但它确实非常便携，可以在应用程序与其环境之间实现清晰的职责分离。这里面大部分的工具和集成示例都是能根据环境手动容器化的， 也可以使用外部垂直整合的PaaS来实现，比如[Deis](http://deis.io)

If you’re not familiar with Deis, its one of several competitors in the open source platform-as-a-service space which allows you to run your own PaaS on a public or private cloud. Like many, Deis is inspired by Heroku. So instead of Dockerfiles, Deis uses a buildpack to transform a code repository into an executable image and a Procfile to specify an app’s processes. Finally, by default you can use a specialized git receiver to complete a deploy. Instead of having to manage separate build, release, and deploy stages yourself like we described above, deploying an app to Deis could be a simple as

如果你不熟悉Deis，它是开源的Paas服务领域的几个竞争对手之一，它允许您在公共或私有云上运行自己的PaaS。像很多人一样，Deis的灵感来自Heroku。因此，代替Dockerfiles，Deis使用buildpack将代码库转换为可执行映像，并使用Procfile来指定应用程序的进程。最后，默认情况下，您可以使用专门的git接收器来完成部署。像我们上面描述的那样，您不必像以前那样自己管理单独的构建，发布和部署阶段，而是将应用程序部署到Deis中可能很简单

```
git push deis-prod
```

While it can’t get much easier than this, you’re certainly trading control for simplicity. It’s up to you to determine which works best for your business.

虽然它不会比这更容易，但你肯定会为了简化而进行取舍。由你决定哪种方式最适合你的业务。


### About the Author

### 关于作者

Cody A. Ray is an inquisitive, tech-savvy, entrepreneurially-spirited dude. Currently, he is a software engineer at Signal, an amazing startup in downtown Chicago, where he gets to work with a dream team that’s changing the service model underlying the Internet.

Cody A. Ray是一位好奇，技术精湛，富有企业精神的家伙。他目前是芝加哥市中心的一家非常出色的初创企业Signal的软件工程师，在那里他与一个正在改变互联网基础服务模式的梦想团队合作。