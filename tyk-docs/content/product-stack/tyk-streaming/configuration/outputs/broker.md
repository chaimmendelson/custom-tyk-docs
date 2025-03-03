---
title: broker
slug: broker
type: output
status: stable
categories: ["Utility"]
---

Allows you to route messages to multiple child outputs using a range of brokering [patterns](#patterns).

## Common

```yml
# Common config fields, showing default values
output:
  label: ""
  broker:
    pattern: fan_out
    outputs: [] # No default (required)
    batching:
      count: 0
      byte_size: 0
      period: ""
      check: ""
```

## Advanced

```yml
# All config fields, showing default values
output:
  label: ""
  broker:
    copies: 1
    pattern: fan_out
    outputs: [] # No default (required)
    batching:
      count: 0
      byte_size: 0
      period: ""
      check: ""
      processors: [] # No default (optional)
```

Processors can be listed to apply across individual outputs or all outputs:

```yaml
output:
  broker:
    pattern: fan_out
    outputs:
      - resource: foo
      - resource: bar
        # Processors only applied to messages sent to bar.
        processors:
          - resource: bar_processor

  # Processors applied to messages sent to all brokered outputs.
  processors:
    - resource: general_processor
```

## Fields

### copies

The number of copies of each configured output to spawn.


Type: `int`  
Default: `1`  

### pattern

The brokering pattern to use.


Type: `string`  
Default: `"fan_out"`  
Options: `fan_out`, `fan_out_fail_fast`, `fan_out_sequential`, `fan_out_sequential_fail_fast`, `round_robin`, `greedy`.

### outputs

A list of child outputs to broker.


Type: `array`  

### batching

Allows you to configure a [batching policy]({{< ref "/product-stack/tyk-streaming/configuration/common-configuration/batching#batch-policy" >}}).


Type: `object`  

```yml
# Examples

batching:
  byte_size: 5000
  count: 0
  period: 1s

batching:
  count: 10
  period: 1s

batching:
  check: this.contains("END BATCH")
  count: 0
  period: 1m
```

### batching.count

A number of messages at which the batch should be flushed. If `0` disables count based batching.


Type: `int`  
Default: `0`  

### batching.byte_size

An amount of bytes at which the batch should be flushed. If `0` disables size based batching.


Type: `int`  
Default: `0`  

### batching.period

A period in which an incomplete batch should be flushed regardless of its size.


Type: `string`  
Default: `""`  

```yml
# Examples

period: 1s

period: 1m

period: 500ms
```

<!-- TODO: when bloblang is supported
### batching.check

A Bloblang query that should return a boolean value indicating whether a message should end a batch.


Type: `string`  
Default: `""`  

```yml
# Examples

check: this.type == "end_of_transaction"
```
-->

### batching.processors

A list of processors to apply to a batch as it is flushed. This allows you to aggregate and archive the batch however you see fit. Please note that all resulting messages are flushed as a single batch, therefore splitting the batch into smaller batches using these processors is a no-op.


Type: `array`  

```yml
# Examples

processors:
  - archive:
      format: concatenate

processors:
  - archive:
      format: lines

processors:
  - archive:
      format: json_array
```

## Patterns

The broker pattern determines the way in which messages are allocated and can be chosen from the following:

### fan_out

With the fan out pattern all outputs will be sent every message that passes through Tyk Streams in parallel.

If an output applies back pressure it will block all subsequent messages, and if an output fails to send a message it will be retried continuously until completion or service shut down. This mechanism is in place in order to prevent one bad output from causing a larger retry loop that results in a good output from receiving unbounded message duplicates.

### fan_out_fail_fast

The same as the `fan_out` pattern, except that output failures will not be automatically retried. This pattern should be used with caution as busy retry loops could result in unlimited duplicates being introduced into the non-failure outputs.

### fan_out_sequential

Similar to the fan out pattern except outputs are written to sequentially, meaning an output is only written to once the preceding output has confirmed receipt of the same message.

If an output applies back pressure it will block all subsequent messages, and if an output fails to send a message it will be retried continuously until completion or service shut down. This mechanism is in place in order to prevent one bad output from causing a larger retry loop that results in a good output from receiving unbounded message duplicates.

### fan_out_sequential_fail_fast

The same as the `fan_out_sequential` pattern, except that output failures will not be automatically retried. This pattern should be used with caution as busy retry loops could result in unlimited duplicates being introduced into the non-failure outputs.

### round_robin

With the round robin pattern each message will be assigned a single output following their order. If an output applies back pressure it will block all subsequent messages. If an output fails to send a message then the message will be re-attempted with the next input, and so on.

### greedy

The greedy pattern results in higher output throughput at the cost of potentially disproportionate message allocations to those outputs. Each message is sent to a single output, which is determined by allowing outputs to claim messages as soon as they are able to process them. This results in certain faster outputs potentially processing more messages at the cost of slower outputs.
