title: Raft：一种分布式一致性算法
author: tinker
date: 2020-07-26 20:01:25
tags:
---
## 什么是分布式一致性

分布式一致性（Distributed Consensus）简单来说就是在多个节点组成系统中各个节点的数据保持一致，并且可以承受某些节点数据不一致或操作失败造成的影响。分布式一致性是分布式系统的基石。

<!--more-->

根据CAP理论，分布式系统在满足P情况下，需要在C和A之间找到平衡。根据C的情况，数据一致性模型分为：

- 强一致性

    新的数据一旦写入，在任意副本任意时刻都能读到新值。强一致性使用的是同步复制，即某节点受到请求之后，必须保证其他所有节点也全部完成同样操作，才算这次请求成功完成。
- 弱一致性

    不同副本上的值有新有旧，这需要应用方做更多的工作获取最新值
- 最终一致性
    
    各副本的数据最终将达到一致。一般使用异步复制，这意味有更好的性能，但需要更复杂的状态控制

![CAP理论](https://static.cyub.vip/images/202007/cap.png)



## Raft

在Raft协议出来之前，Paxos是分布式领域的事实标准。Raft协议把Leader选举、日志复制、安全性等功能分离并模块化，相比Paxos更容易实现与应用。Raft算法属于强一致性算法实现。

### 状态（State)

在Raft中，每个节点在同一时刻只能处于以下三种状态之一：

- 领导者(Leader)
- 候选者(Candidate)
- 跟随者(Follower)


在Raft中Leader负责所有数据的读写，Follower只能用来接受Leader的Replication log。

![raft state](https://static.cyub.vip/images/202007/raft_state2.webp)

### 任期(Terms)

每次选举都会产生一个Term周期，在一个Term内选举一个Leader，该Leader会服务到该Terms周期结束。Term是连续增长的编号，每此选举过程中都会产生一个新的Term。即使选举过程出现投票无效（比如没有任何一个Candidate获得半数以上投票，称为split votes)，会随后立即再次开始产生新的term和一次选举。

![](https://static.cyub.vip/images/202007/raft_term.webp)


### 选举(Leader Election)

Raft中Leader会周期性发送心跳(HeartBeat)给所有的Follower，用来同步Replication log提交的commitIndex,Follower收到指令会进行Replication log，继续保持Follower状态。

![Raft选举](https://static.cyub.vip/images/202007/leader_election.gif)


- 当一个节点刚开始启动时候默认都是Follwer状态，若在一段时间内，没有收到Leader的心跳，就会开始Leader Election过程：该节点会变成Canidate，将当前term技术加+1，同时投个自己一票，然后向其他节点发起投票请求， 若获得集群中大多数节点投票，则该节点会成Leader，然后开始向集群中发布心跳。

- 节点启动时候，会随机生成一个,这保证了Leader挂了情况下，同一时间点不会是所有节点都发起选举，而是只有部分节点发起选举，他们在其他节点选举超时钱选出新的Leader即可。

- 多个节点同时发起选举，参与投票节点会基于first-come-first-served原则进行投票。发起节点发送选举时候会带上自身term信息，参与投票节点会与其自身信息进行比较，当请求投票的该Candidate的Term较大或Term相同Index更大则投票，否则拒绝该请求。这也保证了Leader Completeness。

- 在选举期间，Candidate可能收到来自其它自称为Leader的写请求，如果该Leader的term不小于Candidate的当前term，那么Candidate承认它是一个合法的Leader并回到Follower状态，否则拒绝请求。如果出现两个Candidate得票一样多，则它们都无法获取超过半数投票，这种情况会持续到超时，然后进行新一轮的选举。

### 日志复制(Log Replication)

![日志复制](https://static.cyub.vip/images/202007/log_replication.webp)

来自所有的客户端的请求都会首先经过Leader处理，这些请求先会被包装成一个个带有序号的日志实体(log entry)。每个log entry都包含任期编号(Term)和序号(Index)。Leader首先会将这些日志追加到本地Log中，然后通过心跳机制将该Entry同步到Follower， Follower接收到日志后，记录日志然后想Leader发送ACK，当Leader收到大多数（n/2+1）Follower的ACK信息后将该日志设置为已提交并追加到本地磁盘中，通知客户端并在下个心跳中Leader将通知所有的Follower将该日志存储在自己的本地磁盘中。

若Follower中出现与Leader数据不一致的情况(比如follower中可能会出现leader中没有的log entry，也可能follower中缺少了一些log entry)。Leader会强制Follower复制自己的log entry:


![日志格式](https://static.cyub.vip/images/202007/log_entry.webp)


### 安全性(Safety)

安全性是用于保证每个节点都执行相同序列的安全机制，如当某个Follower在当前Leader commit Log时变得不可用了，稍后可能该Follower又会倍选举为Leader，这时新Leader可能会用新的Log覆盖先前已committed的Log，这就是导致节点执行不同序列；Safety就是用于保证选举出来的Leader一定包含先前 commited Log的机制；

- Election Safety
    每个Term只能选举出一个Leader，假设某个Term同时选举产生两个LeaderA和LeaderB，根据选举过程定义，A和B必须同时获得超过半数节点的投票，至少存在节点N同时给予A和B投票，因此矛盾。
- Leader Completeness
    这里所说的完整性是指Leader日志的完整性，当Log在Term1被Commit后，那么以后Term2、Term3…等的Leader必须包含该Log；Raft在选举阶段就使用Term的判断用于保证完整性：当请求投票的该Candidate的Term较大或Term相同Index更大则投票，否则拒绝该请求；
- Leader Append-Only
    Leader从不“重写”或者“删除”本地Log，仅仅“追加”本地Log。Raft算法中Leader权威至高无上，当Follower和Leader产生分歧的时候，永远是Leader去覆盖修正Follower。
- Log Matching
    如果两个节点上的日志项拥有相同的Index和Term，那么这两个节点[0, Index]范围内的Log完全一致。
- State Machine Safety
    一旦某个server将某个日志项应用于本地状态机，以后所有server对于该偏移都将应用相同日志项。



## 参考

- [图解Raft：最简单易懂的分布式一致性算法](https://juejin.im/post/5ce26587e51d4510936fdc54)
- [Understanding Distributed Consensus with Raft](https://medium.com/@kasunindrasiri/understanding-raft-distributed-consensus-242ec1d2f521)
- [图解Raft之日志复制](https://juejin.im/entry/5b833cf2518825430367030b)
- [由Consul谈到Raft](https://juejin.im/entry/59cbbd3cf265da06507542d7)
- [分布式一致性机制整理](https://segmentfault.com/a/1190000014503967)
- [Raft协议交互式教程](http://thesecretlivesofdata.com/raft/)
- [理解分布式一致性与Raft算法](https://www.cnblogs.com/mokafamily/p/11303534.html)