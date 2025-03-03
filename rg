如果你希望通过脚本自动化匹配 Aurora 集群的 Writer Endpoint 和实例的 Endpoint，你可以使用 AWS CLI 和 Shell 脚本 来完成这个任务。

下面是一个 Bash 脚本 示例，它会自动获取 Aurora 集群的 Writer Endpoint，然后与 Aurora 集群中所有实例的 Endpoint 进行匹配，最终输出 Writer 实例的标识符。

脚本步骤：

1. 获取 Aurora 集群的 Writer Endpoint。


2. 获取与该集群相关的所有实例的 Endpoint。


3. 比较 Writer Endpoint 和实例的 Endpoint，找到匹配的实例。



脚本示例：

#!/bin/bash

# 设置 Aurora 集群的 DBClusterIdentifier
CLUSTER_IDENTIFIER="your-cluster-id"

# 获取 Aurora 集群的 Writer Endpoint
WRITER_ENDPOINT=$(aws rds describe-db-clusters --query "DBClusters[?DBClusterIdentifier=='$CLUSTER_IDENTIFIER'].Endpoint" --output text)

# 获取与 Aurora 集群关联的所有实例的 DBInstanceIdentifier 和 Endpoint
INSTANCES=$(aws rds describe-db-instances --query "DBInstances[?DBClusterIdentifier=='$CLUSTER_IDENTIFIER'].{DBInstanceIdentifier:DBInstanceIdentifier, Endpoint:Endpoint}" --output json)

# 遍历实例并与 Writer Endpoint 匹配
for instance in $(echo "$INSTANCES" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${instance} | base64 --decode | jq -r ${1}
    }

    INSTANCE_IDENTIFIER=$(_jq '.DBInstanceIdentifier')
    INSTANCE_ENDPOINT=$(_jq '.Endpoint')

    # 如果实例的 Endpoint 与 Writer Endpoint 匹配，则是 Writer 实例
    if [[ "$INSTANCE_ENDPOINT" == "$WRITER_ENDPOINT" ]]; then
        echo "Writer Instance: $INSTANCE_IDENTIFIER"
        break
    fi
done

脚本说明：

1. CLUSTER_IDENTIFIER：将其替换为你的 Aurora 集群的 DBClusterIdentifier。


2. aws rds describe-db-clusters --query "DBClusters[?DBClusterIdentifier=='$CLUSTER_IDENTIFIER'].Endpoint"：这个命令会获取 Aurora 集群的 Writer Endpoint。


3. aws rds describe-db-instances --query "DBInstances[?DBClusterIdentifier=='$CLUSTER_IDENTIFIER']..."：这个命令获取与 Aurora 集群相关的所有实例的 DBInstanceIdentifier 和 Endpoint。


4. jq：该工具用于解析 JSON 输出，并提取实例的标识符和 Endpoint 信息。需要提前安装 jq。


5. if [[ "$INSTANCE_ENDPOINT" == "$WRITER_ENDPOINT" ]]：此条件判断会将实例的 Endpoint 与 Writer Endpoint 进行匹配。如果匹配，则输出当前实例是 Writer 实例。



运行脚本：

确保你已经安装了 AWS CLI 和 jq。

将脚本保存为一个 .sh 文件（例如 find_writer_instance.sh）。

给脚本执行权限：chmod +x find_writer_instance.sh。

执行脚本：./find_writer_instance.sh。


脚本输出：

如果脚本找到匹配的 Writer 实例，会输出：

Writer Instance: my-aurora-instance-2

如果没有找到匹配的实例，脚本不会输出任何内容。

小结：

这个脚本通过自动化查询 Aurora 集群的 Writer Endpoint 和所有实例的 Endpoint，确保不需要手动干预即可找到 Writer 实例。

你可以将这个脚本集成到自动化运维工具或调度任务中，以便自动运行。


